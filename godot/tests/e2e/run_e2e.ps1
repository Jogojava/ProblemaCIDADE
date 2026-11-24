[CmdletBinding()]
param(
    [ValidateSet("all", "1", "2", "3", "4")]
    [string]$Tier = "all",
    [string]$Suite = "",
    [string]$Case = "",
    [string]$GodotPath = "",
    [switch]$IncludeIntegration,
    [switch]$StopOnFailure,
    [switch]$List,
    [int]$TimeoutSec = 120
)

$ErrorActionPreference = "Stop"

$DefaultGodot = "C:\Program Files (x86)\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe"
$ResolvedGodot = if (-not [string]::IsNullOrWhiteSpace($GodotPath)) {
    $GodotPath
} elseif (-not [string]::IsNullOrWhiteSpace($env:GODOT_BIN)) {
    $env:GODOT_BIN
} else {
    $DefaultGodot
}

if (-not (Test-Path -LiteralPath $ResolvedGodot)) {
    Write-Error "Godot binary not found at: $ResolvedGodot"
    exit 1
}

$GodotDir = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$RepoRoot = Split-Path -Parent $GodotDir
$ExpectedSiteCommit = "c004bfe0cdc46a324092b83b6a675f8a6926df09"
$FatalStderrPattern = "SCRIPT ERROR:|Parse Error:|Failed to load script|ERROR: Failed to open"

$AllSuites = @(
    @{ Name = "tier1_core"; Tier = "1" },
    @{ Name = "tier1_ui_cleanup"; Tier = "1" },
    @{ Name = "tier2_core"; Tier = "2" },
    @{ Name = "tier2_ui_cleanup"; Tier = "2" },
    @{ Name = "tier3_pairwise"; Tier = "3" },
    @{ Name = "tier4_scenarios"; Tier = "4" }
)

function Invoke-GodotHeadless {
    param(
        [string[]]$GodotArgs,
        [string]$TempRoot
    )
    $id = [guid]::NewGuid().ToString("N")
    $outFile = Join-Path $TempRoot "stdout_$id.txt"
    $errFile = Join-Path $TempRoot "stderr_$id.txt"
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $proc = Start-Process -FilePath $ResolvedGodot -ArgumentList $GodotArgs -PassThru -NoNewWindow -RedirectStandardOutput $outFile -RedirectStandardError $errFile
    $exited = $proc.WaitForExit($TimeoutSec * 1000)
    $timedOut = $false
    if (-not $exited) {
        $timedOut = $true
        try { $proc.Kill() } catch {}
        try { $proc.WaitForExit(3000) | Out-Null } catch {}
    }
    $sw.Stop()
    $stdout = if (Test-Path $outFile) { Get-Content -LiteralPath $outFile -Raw -Encoding UTF8 } else { "" }
    $stderr = if (Test-Path $errFile) { Get-Content -LiteralPath $errFile -Raw -Encoding UTF8 } else { "" }
    Remove-Item -LiteralPath $outFile, $errFile -Force -ErrorAction SilentlyContinue
    if ($timedOut) {
        $stderr = ("E2E_TIMEOUT after {0}s`n" -f $TimeoutSec) + $stderr
    }
    $hasFatalStderr = $timedOut -or ($stderr -match $FatalStderrPattern) -or ($stdout -match $FatalStderrPattern)
    $exitCode = if ($timedOut) { 124 } else { $proc.ExitCode }
    return [pscustomobject]@{
        ExitCode       = $exitCode
        Stdout         = $stdout
        Stderr         = $stderr
        HasFatalStderr = $hasFatalStderr
        ElapsedSec     = [math]::Round($sw.Elapsed.TotalSeconds, 2)
    }
}

$tempAppData = Join-Path $env:TEMP ("probcidade_e2e_" + [guid]::NewGuid().ToString("N"))
$tempLogs = Join-Path $env:TEMP ("probcidade_e2e_logs_" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $tempAppData, $tempLogs | Out-Null
$prevAppData = $env:APPDATA
$env:APPDATA = $tempAppData

try {
    if ($List) {
        $listArgs = @("--headless", "--audio-driver", "Dummy", "--path", $GodotDir, "--script", "res://tests/e2e/e2e_runner.gd", "--", "--list", "--tier=$Tier")
        if (-not [string]::IsNullOrWhiteSpace($Suite)) { $listArgs += "--suite=$Suite" }
        if (-not [string]::IsNullOrWhiteSpace($Case)) { $listArgs += "--case=$Case" }
        $res = Invoke-GodotHeadless -GodotArgs $listArgs -TempRoot $tempLogs
        if ($res.Stdout) { Write-Output $res.Stdout.TrimEnd() }
        if ($res.HasFatalStderr) {
            Write-Host "E2E_FATAL_STDERR:" -ForegroundColor Red
            Write-Host $res.Stderr
            exit 1
        }
        exit $res.ExitCode
    }

    $overallFailures = 0
    $totalSuitesRun = 0
    $totalCasesRun = 0
    $totalChecksRun = 0
    $totalCheckFailures = 0

    $runPreflight = ([string]::IsNullOrWhiteSpace($Case) -and [string]::IsNullOrWhiteSpace($Suite) -and ($Tier -eq "all" -or $Tier -eq "1"))
    if ($runPreflight) {
        Write-Host "=== E2E Pre-Flight Probes ==="
        $branch = (& git -C $RepoRoot branch --show-current 2>&1).Trim()
        $siteRef = (& git -C $RepoRoot rev-parse refs/heads/site 2>&1).Trim()
        $siteDiff = (& git -C $RepoRoot diff $ExpectedSiteCommit refs/heads/site -- 2>&1)
        if ($branch -ne "main" -or $siteRef -ne $ExpectedSiteCommit -or ($siteDiff -and $siteDiff.Count -gt 0)) {
            Write-Host "E2E_PREFLIGHT_FAIL git branch='$branch' site='$siteRef'" -ForegroundColor Red
            $overallFailures++
        } else {
            Write-Host "E2E_PREFLIGHT_PASS git branch=main site=$ExpectedSiteCommit"
        }

        $menuProbe = Invoke-GodotHeadless -GodotArgs @("--headless", "--audio-driver", "Dummy", "--path", $GodotDir, "--scene", "res://scenes/ui/main_menu.tscn", "--quit-after", "2") -TempRoot $tempLogs
        if ($menuProbe.ExitCode -ne 0 -or $menuProbe.HasFatalStderr) {
            Write-Host "E2E_PREFLIGHT_FAIL main_menu.tscn parse exit=$($menuProbe.ExitCode)" -ForegroundColor Red
            if ($menuProbe.Stderr) { Write-Host $menuProbe.Stderr }
            $overallFailures++
        } else {
            Write-Host "E2E_PREFLIGHT_PASS main_menu.tscn parse ($($menuProbe.ElapsedSec)s)"
        }

        $gameProbe = Invoke-GodotHeadless -GodotArgs @("--headless", "--audio-driver", "Dummy", "--path", $GodotDir, "--scene", "res://scenes/game/Game.tscn", "--quit") -TempRoot $tempLogs
        if ($gameProbe.ExitCode -ne 0 -or $gameProbe.HasFatalStderr) {
            Write-Host "E2E_PREFLIGHT_FAIL Game.tscn parse exit=$($gameProbe.ExitCode)" -ForegroundColor Red
            if ($gameProbe.Stderr) { Write-Host $gameProbe.Stderr }
            $overallFailures++
        } else {
            Write-Host "E2E_PREFLIGHT_PASS Game.tscn parse ($($gameProbe.ElapsedSec)s)"
        }

        $audioProbe = Invoke-GodotHeadless -GodotArgs @("--headless", "--audio-driver", "Dummy", "--path", $GodotDir, "--script", "res://tests/e2e/e2e_runner.gd", "--", "--probe-audio") -TempRoot $tempLogs
        if ($audioProbe.ExitCode -ne 0 -or $audioProbe.HasFatalStderr) {
            Write-Host "E2E_PREFLIGHT_FAIL audio probe exit=$($audioProbe.ExitCode) $($audioProbe.Stdout.Trim())" -ForegroundColor Yellow
        } else {
            Write-Host "E2E_PREFLIGHT_PASS $($audioProbe.Stdout.Trim())"
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($Case) -or -not [string]::IsNullOrWhiteSpace($Suite)) {
        $runArgs = @("--headless", "--audio-driver", "Dummy", "--path", $GodotDir, "--script", "res://tests/e2e/e2e_runner.gd", "--", "--tier=$Tier")
        if (-not [string]::IsNullOrWhiteSpace($Suite)) { $runArgs += "--suite=$Suite" }
        if (-not [string]::IsNullOrWhiteSpace($Case)) { $runArgs += "--case=$Case" }
        if ($StopOnFailure) { $runArgs += "--stop-on-failure" }

        $res = Invoke-GodotHeadless -GodotArgs $runArgs -TempRoot $tempLogs
        if ($res.Stdout) { Write-Output $res.Stdout.TrimEnd() }
        if ($res.HasFatalStderr) {
            Write-Host "E2E_FATAL_STDERR:" -ForegroundColor Red
            Write-Host $res.Stderr
            $overallFailures++
        }
        if ($res.ExitCode -ne 0) {
            $overallFailures++
        }
        if ($overallFailures -gt 0) { exit 1 } else { exit 0 }
    }

    $targetSuites = $AllSuites | Where-Object { $Tier -eq "all" -or $_.Tier -eq $Tier }
    foreach ($s in $targetSuites) {
        $runArgs = @("--headless", "--audio-driver", "Dummy", "--path", $GodotDir, "--script", "res://tests/e2e/e2e_runner.gd", "--", "--suite=$($s.Name)")
        if ($StopOnFailure) { $runArgs += "--stop-on-failure" }
        $res = Invoke-GodotHeadless -GodotArgs $runArgs -TempRoot $tempLogs
        if ($res.Stdout) {
            foreach ($line in ($res.Stdout -split "`r?`n")) {
                if ($line -and -not $line.StartsWith("E2E_SUMMARY ")) {
                    Write-Output $line
                }
            }
        }
        if ($res.HasFatalStderr) {
            Write-Host "E2E_FATAL_STDERR suite=$($s.Name):" -ForegroundColor Red
            Write-Host $res.Stderr
            $overallFailures++
        }
        if ($res.Stdout -match "E2E_SUMMARY suites=(\d+) cases=(\d+) checks=(\d+) failures=(\d+)") {
            $totalSuitesRun += [int]$Matches[1]
            $totalCasesRun += [int]$Matches[2]
            $totalChecksRun += [int]$Matches[3]
            $totalCheckFailures += [int]$Matches[4]
        }
        if ($res.ExitCode -ne 0) {
            $overallFailures++
            if ($StopOnFailure) { break }
        }
    }

    if ($IncludeIntegration) {
        Write-Host "=== Integration Tests ==="
        foreach ($intScript in @("res://tests/integration/test_campaign.gd", "res://tests/integration/test_city_layout.gd")) {
            $intRes = Invoke-GodotHeadless -GodotArgs @("--headless", "--audio-driver", "Dummy", "--path", $GodotDir, "--script", $intScript, "--", "--test") -TempRoot $tempLogs
            Write-Output $intRes.Stdout.TrimEnd()
            if ($intRes.ExitCode -ne 0 -or $intRes.HasFatalStderr) {
                $overallFailures++
                if ($intRes.HasFatalStderr) { Write-Host $intRes.Stderr -ForegroundColor Red }
            }
        }
    }

    $finalStatus = if ($overallFailures -eq 0 -and $totalCheckFailures -eq 0) { "PASS" } else { "FAIL" }
    Write-Output ("E2E_SUMMARY suites={0} cases={1} checks={2} failures={3} status={4}" -f $totalSuitesRun, $totalCasesRun, $totalChecksRun, $totalCheckFailures, $finalStatus)
    if ($overallFailures -eq 0 -and $totalCheckFailures -eq 0) {
        exit 0
    } else {
        exit 1
    }
}
finally {
    $env:APPDATA = $prevAppData
    Remove-Item -LiteralPath $tempAppData, $tempLogs -Recurse -Force -ErrorAction SilentlyContinue
}

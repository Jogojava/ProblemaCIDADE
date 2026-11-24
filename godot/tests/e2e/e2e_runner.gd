extends SceneTree

const HARNESS_PATH := "res://tests/e2e/e2e_harness.gd"

const SUITES := [
	{"name": "tier1_core", "tier": 1, "path": "res://tests/e2e/suites/tier1_core.gd"},
	{"name": "tier1_ui_cleanup", "tier": 1, "path": "res://tests/e2e/suites/tier1_ui_cleanup.gd"},
	{"name": "tier2_core", "tier": 2, "path": "res://tests/e2e/suites/tier2_core.gd"},
	{"name": "tier2_ui_cleanup", "tier": 2, "path": "res://tests/e2e/suites/tier2_ui_cleanup.gd"},
	{"name": "tier3_pairwise", "tier": 3, "path": "res://tests/e2e/suites/tier3_pairwise.gd"},
	{"name": "tier4_scenarios", "tier": 4, "path": "res://tests/e2e/suites/tier4_scenarios.gd"}
]

func _initialize() -> void:
	call_deferred("_run")

func _parse_args() -> Dictionary:
	var opts := {
		"tier": "all",
		"suite": "",
		"case": "",
		"list": false,
		"stop_on_failure": false,
		"probe_audio": false,
		"probe_test_silent": false
	}
	for arg in OS.get_cmdline_user_args():
		var s := String(arg)
		if s.begins_with("--tier="):
			opts["tier"] = s.substr(7).strip_edges().to_lower()
		elif s.begins_with("--suite="):
			opts["suite"] = s.substr(8).strip_edges()
		elif s.begins_with("--case="):
			opts["case"] = s.substr(7).strip_edges()
		elif s == "--list":
			opts["list"] = true
		elif s == "--stop-on-failure":
			opts["stop_on_failure"] = true
		elif s == "--probe-audio":
			opts["probe_audio"] = true
		elif s == "--probe-test-silent":
			opts["probe_test_silent"] = true
	return opts

func _run() -> void:
	var opts := _parse_args()
	if bool(opts["probe_audio"]):
		await process_frame
		await process_frame
		var settings := root.get_node_or_null("SettingsService")
		var test_mode := bool(settings.get("test_mode")) if settings != null else true
		var music: Variant = settings.get("_music") if settings != null else null
		var playing := false
		var bus := ""
		if music is AudioStreamPlayer:
			playing = (music as AudioStreamPlayer).playing
			bus = (music as AudioStreamPlayer).bus
		print("E2E_AUDIO_PROBE test_mode=%s has_music=%s playing=%s bus=%s" % [str(test_mode), str(music != null), str(playing), bus])
		quit(0 if (not test_mode and music is AudioStreamPlayer and playing and bus == "Music") else 1)
		return

	if bool(opts["probe_test_silent"]):
		await process_frame
		var settings := root.get_node_or_null("SettingsService")
		var test_mode := bool(settings.get("test_mode")) if settings != null else false
		var music: Variant = settings.get("_music") if settings != null else null
		print("E2E_TEST_SILENT_PROBE test_mode=%s has_music=%s" % [str(test_mode), str(music != null)])
		quit(0 if (test_mode and music == null) else 1)
		return

	var harness_script := load(HARNESS_PATH) as GDScript
	if harness_script == null or not harness_script.can_instantiate():
		printerr("E2E_ERROR failed to load harness: %s" % HARNESS_PATH)
		quit(1)
		return

	var loaded_suites: Array[Dictionary] = []
	var registry_summary: Array[Dictionary] = []
	for suite_meta in SUITES:
		var suite_path := String(suite_meta["path"])
		var suite_script := load(suite_path) as GDScript
		if suite_script == null or not suite_script.can_instantiate():
			printerr("E2E_ERROR failed to load suite: %s" % suite_path)
			quit(1)
			return
		var suite_obj: RefCounted = suite_script.new()
		var cases: Array = suite_obj.call("get_cases")
		registry_summary.append({
			"name": suite_meta["name"],
			"tier": suite_meta["tier"],
			"count": cases.size(),
			"cases": cases.duplicate(true)
		})
		loaded_suites.append({
			"meta": suite_meta,
			"obj": suite_obj,
			"cases": cases
		})

	root.set_meta("e2e_suite_registry", registry_summary)

	var tier_filter := String(opts["tier"])
	var suite_filter := String(opts["suite"])
	var case_filter := String(opts["case"])
	var list_only := bool(opts["list"])
	var stop_on_failure := bool(opts["stop_on_failure"])

	var selected: Array[Dictionary] = []
	for item in loaded_suites:
		var meta: Dictionary = item["meta"]
		if tier_filter != "all" and str(meta["tier"]) != tier_filter:
			continue
		if not suite_filter.is_empty() and String(meta["name"]) != suite_filter and not String(meta["name"]).contains(suite_filter):
			continue
		var matched_cases: Array = []
		for c in item["cases"]:
			var cid := String(c.get("id", ""))
			if case_filter.is_empty() or cid.to_lower().contains(case_filter.to_lower()):
				matched_cases.append(c)
		if not matched_cases.is_empty():
			selected.append({
				"meta": meta,
				"obj": item["obj"],
				"cases": matched_cases
			})

	if list_only:
		var total_listed := 0
		for item in selected:
			var meta: Dictionary = item["meta"]
			for c in item["cases"]:
				total_listed += 1
				print("%s\t[Tier %s]\t%s" % [String(c["id"]), str(meta["tier"]), String(c.get("description", ""))])
		print("E2E_LIST total=%d" % total_listed)
		quit(0)
		return

	if selected.is_empty():
		print("E2E_SUMMARY suites=0 cases=0 checks=0 failures=1 status=FAIL msg=No matching cases")
		quit(1)
		return

	var total_suites := 0
	var total_cases := 0
	var total_checks := 0
	var total_failures := 0
	var aborted := false

	for item in selected:
		if aborted:
			break
		var meta: Dictionary = item["meta"]
		var suite_name := String(meta["name"])
		var tier_num := int(meta["tier"])
		var suite_obj: RefCounted = item["obj"]
		var cases: Array = item["cases"]
		var harness: RefCounted = harness_script.new()
		harness.call("begin_suite", suite_name)
		total_suites += 1
		print("E2E_SUITE_START name=%s tier=%d cases=%d" % [suite_name, tier_num, cases.size()])

		var suite_passed_cases := 0
		for c in cases:
			var case_id := String(c["id"])
			var tag := "%s_%s" % [suite_name, case_id.replace("-", "_")]
			harness.call("setup_isolated_env", self, tag)
			harness.call("begin_case", case_id)
			total_cases += 1
			await suite_obj.call("run_case", harness, self, c)
			var passed := bool(harness.call("end_case"))
			await harness.call("cleanup_scene", self)
			harness.call("cleanup_isolated_env", self, tag)
			if passed:
				suite_passed_cases += 1
				print("E2E_PASS suite=%s case=%s" % [suite_name, case_id])
			else:
				var msgs: Array = harness.get("case_failure_messages")
				for m in msgs:
					print("E2E_FAIL suite=%s case=%s msg=%s" % [suite_name, case_id, String(m)])
				if stop_on_failure:
					aborted = true
					break

		var suite_checks := int(harness.get("checks"))
		var suite_failures := int(harness.get("failures"))
		total_checks += suite_checks
		total_failures += suite_failures
		var suite_status := "PASS" if suite_failures == 0 else "FAIL"
		print("E2E_SUITE_END name=%s checks=%d passed=%d failures=%d status=%s" % [suite_name, suite_checks, suite_passed_cases, suite_failures, suite_status])

	var overall_status := "PASS" if total_failures == 0 else "FAIL"
	print("E2E_SUMMARY suites=%d cases=%d checks=%d failures=%d status=%s" % [total_suites, total_cases, total_checks, total_failures, overall_status])
	quit(0 if total_failures == 0 else 1)

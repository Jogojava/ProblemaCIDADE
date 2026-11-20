# Releases do ProblemaCIDADE

Os downloads ficam na página de [Releases](https://github.com/Jogojava/ProblemaCIDADE/releases): um único `.zip` com o jogo para Windows 10/11 e Linux (Debian), 64 bits. Não precisa instalar o Godot.

Os executáveis não ficam dentro do Git (passam do limite de 100 MB por arquivo do GitHub); eles são anexados a cada release.

## Como gerar uma nova versão

1. Instale o Godot 4.7.2 e os modelos de exportação (Windows e Linux).
2. Na raiz do repositório:

   ```bash
   godot --headless --path godot --export-release "Windows Desktop" ../build/windows/ProblemaCIDADE.exe
   godot --headless --path godot --export-release "Linux" ../build/linux/ProblemaCIDADE.x86_64
   ```

   Os dois presets estão em `godot/export_presets.cfg`, com o `.pck` embutido no executável.
3. Junte as duas pastas num `.zip` (`ProblemaCIDADE-vX.Y.Z/Windows` e `ProblemaCIDADE-vX.Y.Z/Linux`, mais um `LEIA-ME.txt`).
4. Publique: `gh release create vX.Y.Z build/ProblemaCIDADE-vX.Y.Z.zip --target releases`.

A pasta `build/` e os `.zip` estão no `.gitignore`.

# La Route

Jeu Godot 4.7 (GDScript) de conduite et de survie : un road trip de 5 000 km.

## Documentation (à lire avant de coder)
- `documentation/GDD.md` : vision cible du jeu complet.
- `documentation/TECH_SPECS.md` : conventions et architecture **obligatoires** (clean code, typage strict, composants, signaux).
- `documentation/versions/` : périmètre de chaque version. **Version en cours : V0.1.**

## Outils
- Godot 4.7.2 (console, pour lancer sans fenêtre, les tests et les logs) : `E:\logiciel_2\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`
  - Exemple : `"<godot>" --headless --path . --quit`
  - Tests : voir TECH_SPECS 3.9. Après ajout d'une classe (`class_name`), lancer d'abord `"<godot>" --headless --path . --import`.

- Blender 5.3 : `E:\logiciel_2\blender\blender.exe` (sans fenêtre : `--background --python script.py`)
- Blender MCP : serveur déclaré dans `.mcp.json` (`uvx mcp-for-blender`, nouveau nom du paquet `blender-mcp` ; add-on installé avec `uvx mcp-for-blender install-addon`). Dans Blender, il faut que l'add-on soit actif et connecté (vue 3D → N → onglet BlenderMCP → Connect).
  - L'extension officielle « MCP » (Blender Lab) doit rester **désactivée** : elle utilise aussi le port 9876.
  - Sources externes (Poly Haven, Sketchfab, générateurs IA) et télémétrie : désactivées, à garder ainsi.

## Règles
- Ne coder que ce qui est dans le périmètre de la version en cours.
- Une décision durable prise pendant une version doit être reportée dans GDD.md ou TECH_SPECS.md.
- Code en anglais, commentaires en français.

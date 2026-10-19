# Learn with Momo

Offline Android learning game (English words: colors, numbers, animals, sea animals, reptiles, flowers, body parts) for a 3-year-old.

## Tools (installed on this PC)

- Godot 4.7.2: `D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe` (use `Godot_v4.7.2-stable_win64.exe` for the editor)
- JDK 17: `D:\Tools\jdk-17.0.20.1+1`
- Android SDK: `D:\Tools\android-sdk`
- Python venv for asset tools: `tools/.venv`

## Run tests

```bash
/d/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests/unit -gexit
```

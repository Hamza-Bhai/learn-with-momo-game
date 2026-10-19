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

## Build the Android APK

Export templates for 4.7.2 live in `%APPDATA%\Godot\export_templates\4.7.2.stable`. The APK is signed with the local debug key `D:\Tools\android-debug.keystore` (sideload only, not for Play Store).

```bash
export GODOT_ANDROID_KEYSTORE_RELEASE_PATH="D:/Tools/android-debug.keystore" GODOT_ANDROID_KEYSTORE_RELEASE_USER=androiddebugkey GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD=android
/d/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --export-release "Android" build/learn-with-momo.apk
```

Output: `build/learn-with-momo.apk` (~56 MB: arm64 + armv7 engine ~50 MB, game content ~4 MB). No permissions, landscape, Android 7+.

## Install on a phone

Copy the APK to the phone (USB / WhatsApp to yourself), open it, allow "Install unknown apps" for that app once.

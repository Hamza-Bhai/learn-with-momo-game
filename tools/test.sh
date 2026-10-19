#!/usr/bin/env bash
# Runs the GUT unit tests headless. Usage: tools/test.sh  (from repo root)
# Fails if any test fails OR any script fails to load.
G="${GODOT:-/d/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe}"
mkdir -p build
"$G" --headless --path . --import >/dev/null 2>&1
"$G" --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests/unit -gexit > build/test.log 2>&1
code=$?
clean=$(sed 's/\x1b\[[0-9;]*m//g' build/test.log)
echo "$clean" | grep -E "^(Scripts|Tests|Passing|Failing|Asserts|Risky|Pending)|SCRIPT ERROR|Failed to load|All tests passed|\[Failed\]|^    \S" | head -60
if echo "$clean" | grep -qE "SCRIPT ERROR|Failed to load script"; then code=1; fi
exit $code

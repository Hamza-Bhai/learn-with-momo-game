#!/usr/bin/env bash
# Renders a screen for N frames and keeps the last frame as build/shots/<name>.png
# Usage: tools/shot.sh <scene_dir> [category] [frames]
G="${GODOT:-/d/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe}"
name=$1; cat=${2:-colors}; frames=${3:-45}
out=build/shots/tmp_$name; rm -rf "$out"; mkdir -p "$out"
"$G" --path . --resolution 1280x720 --fixed-fps 30 --write-movie "$out/f.png" --quit-after "$frames" \
  -- --start=res://scenes/$name/$name.tscn --cat=$cat > "build/shots/$name.log" 2>&1
last=$(ls "$out"/*.png | tail -1); cp "$last" "build/shots/$name.png"; rm -rf "$out"
sed 's/\x1b\[[0-9;]*m//g' "build/shots/$name.log" | grep -E "SCRIPT ERROR|ERROR:|WARNING:" | grep -v "Movie Maker" | head -8

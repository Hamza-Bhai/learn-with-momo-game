"""Download Twemoji SVGs for every emoji item and for the UI icons.

Usage (repo root): tools/.venv/Scripts/python tools/fetch_images.py
Exits non-zero and prints the ids it could not find.
"""
import json
import pathlib
import sys
import urllib.error
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parent.parent
BASE = "https://cdn.jsdelivr.net/gh/jdecked/twemoji@15.1.0/assets/svg/%s.svg"

UI = {
    "momo": "🐵", "star": "⭐", "album": "📒", "lock": "🔒", "arrow_left": "⬅️", "arrow_right": "➡️",
    "learn": "📖", "play": "▶️", "parent": "⚙️", "apple": "🍎",
    "outfit_crown": "👑", "outfit_top_hat": "🎩", "outfit_cap": "🧢", "outfit_sunglasses": "🕶️",
    "outfit_bow": "🎀", "outfit_grad_cap": "🎓", "outfit_flower": "🌸", "outfit_helmet": "⛑️",
}


def twemoji_name(emoji: str) -> str:
    cps = [f"{ord(ch):x}" for ch in emoji]
    if "200d" not in cps:
        cps = [c for c in cps if c != "fe0f"]
    return "-".join(cps)


def fetch(emoji: str, dest: pathlib.Path) -> bool:
    if dest.exists():
        return True
    try:
        with urllib.request.urlopen(BASE % twemoji_name(emoji), timeout=30) as r:
            dest.write_bytes(r.read())
        return True
    except urllib.error.URLError:
        return False


def main() -> int:
    items_dir = ROOT / "assets/images/items"
    ui_dir = ROOT / "assets/images/ui"
    items_dir.mkdir(parents=True, exist_ok=True)
    ui_dir.mkdir(parents=True, exist_ok=True)
    missing = []
    for path in sorted((ROOT / "data/items").glob("*.json")):
        for it in json.loads(path.read_text(encoding="utf-8")):
            if "emoji" in it and not fetch(it["emoji"], items_dir / f"{it['id']}.svg"):
                missing.append(it["id"])
    for name, emoji in UI.items():
        if not fetch(emoji, ui_dir / f"{name}.svg"):
            missing.append(name)
    if missing:
        print("MISSING:", ", ".join(missing))
        return 1
    print("all images ok")
    return 0


if __name__ == "__main__":
    sys.exit(main())

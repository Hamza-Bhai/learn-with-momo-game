"""Generate every voice line of the game with Piper TTS, as OGG files.

Usage (repo root):
  tools/.venv/Scripts/python tools/gen_voice.py --voice amy [--force]
  tools/.venv/Scripts/python tools/gen_voice.py --voice amy --sample   # 3 demo lines -> build/samples/
"""
import argparse
import json
import pathlib
import subprocess
import sys
import wave

from piper import PiperVoice, SynthesisConfig

ROOT = pathlib.Path(__file__).resolve().parent.parent
VOICES = pathlib.Path("D:/Tools/piper-voices")
OUT = ROOT / "assets/audio/voice"
WAV = ROOT / "build/voice"
LENGTH_SCALE = 1.15  # a bit slower than normal speech
COUNT_UP_TO = 10  # numbers above this are named but not counted aloud

ONES = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"]


def article(word: str) -> str:
    return "an" if word[0] in "aeiou" else "a"


def item_lines(it: dict) -> dict:
    name = it["name"]
    if "color" in it:
        this, where = f"This is {name}.", f"Where is {name}?"
    elif "number" in it:
        n = int(it["number"])
        this = f"This is {name}."
        if n <= COUNT_UP_TO:
            this += " " + ", ".join(ONES[:n]).capitalize() + "!"
        where = f"Where is number {name}?"
    else:
        this, where = f"This is {article(name)} {name}.", f"Where is the {name}?"
    return {
        f"this_{it['id']}": it.get("this", this),
        f"where_{it['id']}": it.get("where", where),
        f"name_{it['id']}": name.capitalize() + "!",
    }


def all_lines() -> dict:
    lines = {}
    for c in json.loads((ROOT / "data/categories.json").read_text(encoding="utf-8")):
        lines[f"cat_{c['id']}"] = c["name"] + "!"
        for it in json.loads((ROOT / f"data/items/{c['id']}.json").read_text(encoding="utf-8")):
            lines.update(item_lines(it))
    lines.update(json.loads((ROOT / "data/phrases.json").read_text(encoding="utf-8")))
    return lines


def synth(voice: PiperVoice, text: str, wav_path: pathlib.Path, ogg_path: pathlib.Path) -> None:
    wav_path.parent.mkdir(parents=True, exist_ok=True)
    ogg_path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(wav_path), "wb") as wf:
        voice.synthesize_wav(text, wf, syn_config=SynthesisConfig(length_scale=LENGTH_SCALE))
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", str(wav_path),
                    "-af", "adelay=150|150,apad=pad_dur=0.2",
                    "-ac", "1", "-ar", "22050", "-c:a", "libvorbis", "-q:a", "3", str(ogg_path)], check=True)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--voice", required=True, choices=["amy", "lessac"])
    ap.add_argument("--force", action="store_true")
    ap.add_argument("--sample", action="store_true")
    a = ap.parse_args()
    voice = PiperVoice.load(str(VOICES / f"en_US-{a.voice}-medium.onnx"))
    if a.sample:
        text = "Hello! I am Momo. Let's play! Where is the turtle? This is three. One, two, three! Great job!"
        out = ROOT / f"build/samples/sample_{a.voice}.ogg"
        synth(voice, text, WAV / f"sample_{a.voice}.wav", out)
        print(out)
        return 0
    lines = all_lines()
    made = 0
    for key, text in lines.items():
        ogg = OUT / f"{key}.ogg"
        if ogg.exists() and not a.force:
            continue
        synth(voice, text, WAV / f"{key}.wav", ogg)
        made += 1
    print(f"{made} generated, {len(lines)} total")
    return 0


if __name__ == "__main__":
    sys.exit(main())

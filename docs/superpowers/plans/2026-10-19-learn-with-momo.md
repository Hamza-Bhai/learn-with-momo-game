# Learn with Momo Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (inline — user forbids subagents) to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** An offline Android learning game for a 3-year-old: English names of colors, numbers, animals, sea animals, reptiles, flowers and body parts, with Momo the monkey, stickers and a parent-set time limit.

**Architecture:** Godot 4 project. All content lives in JSON (`data/`); pure-logic GDScript classes (`scripts/core/`) hold rounds, progress, timer and parent gate and are unit-tested with GUT headless; scenes (`scenes/`) are thin UI on top. Python tools (`tools/`) generate assets from the JSON: Twemoji SVGs and Piper TTS voice files.

**Tech Stack:** Godot 4 (latest 4.x stable, GDScript, Compatibility renderer), GUT 9.x, Python 3.12 + piper-tts, ffmpeg (already installed), Twemoji 15.1.0 (jdecked fork, CC-BY 4.0), Kenney CC0 sound packs.

**Spec:** `docs/superpowers/specs/2026-10-19-learn-with-momo-design.md`

## Global Constraints

- Android APK, sideloaded; must run smoothly on Infinix 2GB RAM / 16GB. APK target < 50 MB.
- Renderer: Compatibility (GLES3). Orientation: landscape.
- Fully offline: no INTERNET permission, no ads, no purchases, no outbound links, no analytics.
- No screen requires reading; every button speaks its name on tap.
- Wrong answer = wiggle + "Try again!" only. No buzzer, no red X, no score loss, no sad Momo.
- Nothing auto-advances in Learn (no feed behaviour).
- Play round = 5 questions; 2 options, rising to 3.
- Time limit options: Off / 10 / 15 / 20 / 30 min; daily total, resets at local midnight; counts only while the app is in the foreground.
- Voice: pre-generated Piper TTS, slightly slow (length_scale 1.15), OGG Vorbis mono.
- Downloads (Godot, export templates, JDK, Android SDK, GUT, piper voices, Twemoji, Kenney) need the user's explicit OK at execution time — ask once with the list.

## Review Focus

1. Toddler mashing taps (double taps, tapping during the "Great job" animation or during scene change) — expect exactly one answer counted per question and never a double sticker. → Task 4 `test_answer_ignored_while_locked`, Task 5 `test_award_twice_same_round_gives_one`.
2. Missing or corrupt `user://save.json` (first run, phone killed mid-write) — expect defaults, no crash. → Task 5 `test_load_corrupt_file_gives_defaults`.
3. Phone date/time changed backwards or forwards — expect timer never negative, new date resets, past date does not grant extra time beyond a reset. → Task 6 `test_clock_backwards_no_negative`.
4. App sent to background (phone call, home button) — expect timer pauses and voice stops. → Task 6 `test_paused_does_not_accumulate` + Task 12 manual check.
5. Android back button on time-up screen or in Play — expect it never unlocks time-up, and elsewhere goes one screen back (Home: ignored, no exit). → Task 12 manual check list.

---

## File Structure

```
project.godot
export_presets.cfg
addons/gut/                     (GUT, vendored)
data/categories.json            ordered list of categories + outfit per category
data/items/<category_id>.json   items of one category
data/phrases.json               common phrases (id -> text)
assets/images/items/<id>.svg    Twemoji per item
assets/images/ui/*.svg          momo, outfits, icons
assets/audio/voice/<key>.ogg    TTS files
assets/audio/sfx/*.ogg          clap, pop, confetti, whoosh
scripts/core/content_db.gd      autoload ContentDB
scripts/core/round_session.gd   class RoundSession (pure logic)
scripts/core/progress.gd        autoload Progress
scripts/core/play_timer.gd      class PlayTimer (pure logic) + autoload TimerService wrapper
scripts/core/parent_gate.gd     class ParentGate
scripts/core/voice.gd           autoload Voice
scripts/core/nav.gd             autoload Nav
scenes/components/momo.tscn/.gd       Momo character
scenes/components/big_button.tscn/.gd speaking button
scenes/home, category, learn, play, reward, album, parents, time_up (.tscn + .gd each)
tests/unit/test_*.gd
tools/fetch_images.py, tools/gen_voice.py, tools/check_assets.py
```

## Data schema (decided here, used by all tasks)

`data/categories.json`:
```json
[{"id": "colors", "name": "Colors", "icon_item": "red", "outfit": "crown", "unlock_after": null},
 {"id": "numbers_2", "name": "More Numbers", "icon_item": "n15", "outfit": "bow", "unlock_after": "numbers_1"}]
```
Order: colors, numbers_1 (one–ten), numbers_2 (eleven–twenty, `unlock_after: numbers_1`), animals, sea_animals, reptiles, flowers, body_parts. Outfits: crown 👑, top_hat 🎩, cap 🧢, sunglasses 🕶️, bow 🎀, grad_cap 🎓, flower 🌸, helmet ⛑️ — one per category in that order.

`data/items/<category>.json` — item ids are globally unique:
```json
[{"id": "turtle", "name": "turtle", "emoji": "🐢", "avoid_with": []},
 {"id": "red", "name": "red", "color": "#E53935", "avoid_with": ["pink", "orange"]},
 {"id": "n3", "name": "three", "number": 3}]
```
Exactly one of `emoji` / `color` / `number`. Optional `this` / `where` override the generated sentences.

Content per spec §8, with these resolved: chameleon dropped (no Twemoji); sea turtle replaced by seal 🦭; hair = 💇; mouth = 👄; eye = 👁️. Twemoji lookups that fail in Task 3 are dropped and noted in the spec.

Voice keys: `this_<id>`, `where_<id>`, `name_<id>`, `cat_<category_id>`, and every key of `phrases.json`.
Sentence rules (in `tools/gen_voice.py`): emoji item → "This is a {name}." / "Where is the {name}?" (`an` before a vowel sound); color → "This is {name}." / "Where is {name}?"; number n → "This is {name}. " + "One, two, … {name}!" (count up to n) / "Where is number {name}?"; name → "{Name}!".
`phrases.json` keys: great_job "Great job!", well_done "Well done!", yay "Yay!", try_again "Try again!", got_sticker "You got a sticker!", learn "Learn", play "Play", album "My stickers", new_outfit "Wow! Momo has a new hat!", bye "Bye bye! See you tomorrow!", hello "Hello! I am Momo. Let's play!".

---

### Task 1: Toolchain, project skeleton, GUT, git

**Files:**
- Create: `project.godot`, `.gitignore`, `addons/gut/`, `tests/unit/test_smoke.gd`, `README.md` (how to run tests / build)

**Interfaces:**
- Produces: test command used by every later task:
  `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests/unit -gexit`
  (`godot` = path to the Godot console exe, recorded in README.)

- [ ] **Step 1:** Ask the user once for permission to download: Godot 4.x stable (Windows + Android export templates, ~100 MB + ~1 GB), Temurin JDK 17, Android command-line tools + platform-tools + build-tools + platform 34, GUT 9.x, piper-tts (pip) + one voice model, Twemoji SVGs, Kenney CC0 audio packs. Install to `D:\Tools\` (Godot, SDK, JDK).
- [ ] **Step 2:** `git init` in `D:\Projects\Android-Games`; `.gitignore` = `.godot/`, `*.apk`, `*.wav`, `tools/.venv/`, `build/`.
- [ ] **Step 3:** Create `project.godot`: name "Learn with Momo", renderer `gl_compatibility`, window 1280×720, stretch mode `canvas_items`, aspect `expand`, orientation landscape, main scene `res://scenes/home/home.tscn` (placeholder Node2D for now). Vendor GUT into `addons/gut/` and enable it.
- [ ] **Step 4:** Write `tests/unit/test_smoke.gd` with `test_truth(): assert_true(true)`; run the test command. Expected: `1 passed`, exit code 0.
- [ ] **Step 5:** Commit spec + plan + skeleton: `chore: project skeleton with GUT`.

### Task 2: Content data + ContentDB

**Files:**
- Create: `data/categories.json`, `data/items/*.json` (8 files), `data/phrases.json`, `scripts/core/content_db.gd`
- Test: `tests/unit/test_content_db.gd`
- Modify: `project.godot` (autoload `ContentDB`)

**Interfaces:**
- Produces (autoload `ContentDB`):
  - `categories() -> Array[Dictionary]` (in file order)
  - `category(id: String) -> Dictionary`
  - `items(category_id: String) -> Array[Dictionary]` — only items whose required assets exist (see Task 3); in test mode (`ContentDB.require_assets = false`) all items
  - `item(id: String) -> Dictionary`
  - `voice_path(key: String) -> String` → `"res://assets/audio/voice/%s.ogg" % key`
  - `image_path(id: String) -> String` → `"res://assets/images/items/%s.svg" % id`

- [ ] **Step 1: Write failing tests** in `test_content_db.gd`:
  - `test_eight_categories_in_order`: ids == `["colors","numbers_1","numbers_2","animals","sea_animals","reptiles","flowers","body_parts"]`
  - `test_item_ids_globally_unique`
  - `test_each_item_has_exactly_one_kind` (emoji/color/number)
  - `test_numbers_1_is_one_to_ten` and `test_numbers_2_is_eleven_to_twenty` (by `number` field)
  - `test_avoid_with_refers_to_same_category_ids`
  - `test_every_category_has_outfit_and_icon_item_exists`
  - `test_each_category_has_at_least_3_items` (Play needs 3 options)
- [ ] **Step 2:** Run test command. Expected: FAIL (ContentDB missing).
- [ ] **Step 3:** Write the JSON files per the schema and spec §8; implement `content_db.gd` (loads all JSON in `_ready`, `FileAccess` + `JSON.parse_string`).
- [ ] **Step 4:** Run tests. Expected: all pass.
- [ ] **Step 5:** Commit `feat: content data and ContentDB`.

### Task 3: Asset pipeline (images, voice, sfx)

**Files:**
- Create: `tools/fetch_images.py`, `tools/gen_voice.py`, `tools/check_assets.py`, `tools/requirements.txt`, `assets/images/items/*.svg`, `assets/images/ui/*.svg`, `assets/audio/voice/*.ogg`, `assets/audio/sfx/{clap,pop,confetti,whoosh,boop}.ogg`, `CREDITS.md`
- Test: `tests/unit/test_assets.gd`

**Interfaces:**
- Consumes: data schema above.
- Produces: every file `ContentDB.image_path` / `voice_path` can return; UI images `momo.svg` (🐵 1f435), `outfit_<id>.svg`, `star.svg`, `album.svg`, `lock.svg`, `arrow_left.svg`, `arrow_right.svg`, `learn.svg` (📖), `play.svg` (▶️), `parent.svg` (⚙️).

- [ ] **Step 1: Failing test** `test_assets.gd`:
  - `test_every_emoji_item_has_image`, `test_every_item_has_this_where_name_voice`, `test_every_category_has_cat_voice`, `test_every_phrase_has_voice`, `test_ui_images_exist`, `test_sfx_exist` (all via `ResourceLoader.exists`).
- [ ] **Step 2:** Run. Expected: FAIL (no assets).
- [ ] **Step 3:** `fetch_images.py`: emoji → Twemoji filename (codepoints in lowercase hex joined by `-`, drop `fe0f` unless the sequence contains `200d`), download from `https://cdn.jsdelivr.net/gh/jdecked/twemoji@15.1.0/assets/svg/<file>.svg`; on 404 print the item id and exit non-zero.
- [ ] **Step 4:** `gen_voice.py`: build every key → sentence (rules above), run Piper (`length_scale=1.15`) to WAV in `build/voice/`, convert with `ffmpeg -ac 1 -ar 22050 -c:a libvorbis -q:a 3`. Generate 3 sample sentences with two voices (`en_US-amy-medium`, `en_US-lessac-medium`) and **let the user pick by listening** before generating all. Skip keys whose OGG already exists unless `--force`.
- [ ] **Step 5:** Pick 5 SFX from Kenney CC0 packs, convert to OGG; write `CREDITS.md` (Twemoji CC-BY 4.0 attribution text, Kenney CC0, Piper voice license).
- [ ] **Step 6:** Run tests. Expected: all pass. Check `du -sh assets` < 15 MB.
- [ ] **Step 7:** Commit `feat: generated images, voice and sfx`.

### Task 4: RoundSession (Play logic)

**Files:**
- Create: `scripts/core/round_session.gd` (`class_name RoundSession extends RefCounted`)
- Test: `tests/unit/test_round_session.gd`

**Interfaces:**
- Produces:
  - `static func options_count(rounds_won: int) -> int` — 2 if `rounds_won < 3`, else 3
  - `func _init(items: Array, rounds_won: int, rng: RandomNumberGenerator, questions := 5)`
  - `func current() -> Dictionary` → `{"target": item_id, "options": Array[String]}` (shuffled)
  - `func answer(item_id: String) -> String` → `"correct" | "wrong" | "ignored"`
  - `func unlock() -> void` — UI calls after the correct-answer animation; advances to next question
  - `func is_finished() -> bool`, `func index() -> int` (0-based question number)
- Rules: targets = 5 distinct items when the category has ≥ 5, else repeats allowed but never twice in a row; distractors from the same category, never in target's `avoid_with` (or target in theirs), no duplicate options; after `"correct"` the session is locked until `unlock()`.

- [ ] **Step 1: Failing tests:** `test_options_count_2_then_3` (0,2 → 2; 3,10 → 3), `test_five_questions`, `test_target_in_options`, `test_options_unique`, `test_avoid_with_respected` (red never with pink/orange), `test_no_same_target_twice_in_a_row` (3-item category, 50 seeds), `test_wrong_keeps_same_question`, `test_answer_ignored_while_locked` (correct → second tap "ignored", index unchanged), `test_finished_after_five_correct_and_unlocks`.
- [ ] **Step 2:** Run. Expected: FAIL.
- [ ] **Step 3:** Implement.
- [ ] **Step 4:** Run. Expected: pass.
- [ ] **Step 5:** Commit `feat: RoundSession logic`.

### Task 5: Progress (stickers, outfits, save)

**Files:**
- Create: `scripts/core/progress.gd` (`class_name ProgressStore extends RefCounted`) + `scripts/core/progress_service.gd` (autoload `Progress`, holds one `ProgressStore` at `user://save.json`)
- Test: `tests/unit/test_progress.gd`

**Interfaces:**
- Produces (`ProgressStore`):
  - `func _init(path: String)`; `func load_or_default() -> void`; `func save() -> void` (write to `path + ".tmp"`, then rename)
  - `func award_sticker(category_id: String, item_ids: Array, round_token: int) -> Dictionary` → `{"sticker": id_or_empty, "outfit": outfit_id_or_empty}`; first unearned id in `item_ids` order; empty `sticker` when page already full; same `round_token` twice → second call returns `{"sticker":"", "outfit":""}`
  - `func has_sticker(item_id) -> bool`, `func page_complete(category_id, item_ids) -> bool`
  - `func rounds_won(category_id) -> int`
  - `func outfits() -> Array[String]`, `func worn_outfit() -> String`, `func set_worn_outfit(id)`
  - `func settings() -> Dictionary` (`limit_minutes: int` default 0 = Off) and `func set_limit_minutes(m: int)` — accepts only 0/10/15/20/30
  - `func reset_progress()` (clears stickers/outfits/rounds, keeps settings)
  - `func timer_state() -> Dictionary` / `func set_timer_state(d)` (used by Task 6)

- [ ] **Step 1: Failing tests:** `test_award_gives_first_unearned_in_order`, `test_award_twice_same_round_gives_one`, `test_page_complete_unlocks_outfit_once`, `test_award_on_full_page_gives_empty_sticker`, `test_rounds_won_increments`, `test_save_load_roundtrip`, `test_load_missing_file_gives_defaults`, `test_load_corrupt_file_gives_defaults` (write `"{not json"`), `test_limit_rejects_other_values` (7 → unchanged), `test_reset_keeps_settings`. Use `user://test_save.json` and delete it in `after_each`.
- [ ] **Step 2:** Run. Expected: FAIL.
- [ ] **Step 3:** Implement.
- [ ] **Step 4:** Run. Expected: pass.
- [ ] **Step 5:** Commit `feat: progress store with stickers and outfits`.

### Task 6: PlayTimer

**Files:**
- Create: `scripts/core/play_timer.gd` (`class_name PlayTimer extends RefCounted`), `scripts/core/timer_service.gd` (autoload `TimerService`)
- Test: `tests/unit/test_play_timer.gd`

**Interfaces:**
- Produces (`PlayTimer`, all time injected for tests):
  - `func _init(state: Dictionary, limit_minutes: int)` — state `{"date": "YYYY-MM-DD", "used_sec": float, "bonus_sec": float}`
  - `func tick(delta_sec: float, today: String) -> void` — if `today != state.date`: reset used and bonus to 0, date = today; ignores negative/huge deltas (`delta < 0` or `> 5` → ignored)
  - `func set_paused(p: bool)`; paused → tick does nothing
  - `func is_time_up() -> bool` — false when limit 0; else `used_sec >= limit*60 + bonus_sec`
  - `func add_bonus_minutes(m: int)`; `func set_limit(m: int)`; `func state() -> Dictionary`
- `TimerService`: ticks in `_process` with `Time.get_date_string_from_system()`, pauses on `NOTIFICATION_APPLICATION_PAUSED` / `FOCUS_OUT`, saves state through `Progress` every 10 s and on pause, emits `signal time_up`.

- [ ] **Step 1: Failing tests:** `test_limit_off_never_up`, `test_up_after_limit` (10 min: 599 s false, 600 s true), `test_paused_does_not_accumulate`, `test_new_date_resets`, `test_clock_backwards_no_negative` (date goes to an earlier string → treated as new date, used = 0, never negative), `test_huge_delta_ignored` (delta 3600), `test_bonus_extends`.
- [ ] **Step 2:** Run. Expected: FAIL.
- [ ] **Step 3:** Implement.
- [ ] **Step 4:** Run. Expected: pass.
- [ ] **Step 5:** Commit `feat: daily play timer`.

### Task 7: ParentGate

**Files:**
- Create: `scripts/core/parent_gate.gd` (`class_name ParentGate extends RefCounted`)
- Test: `tests/unit/test_parent_gate.gd`

**Interfaces:**
- Produces: `static func make(rng: RandomNumberGenerator) -> Dictionary` → `{"text": "7 + 5 = ?", "answer": 12, "choices": Array[int]}` — a, b in 3..9, 4 unique choices including answer, choices within 6..18; `static func check(q: Dictionary, choice: int) -> bool`.
- Shown as text (parents read); this is the only reading screen and is fine per spec.

- [ ] **Step 1: Failing tests:** `test_answer_is_sum`, `test_four_unique_choices_contain_answer` (100 seeds), `test_check`.
- [ ] **Step 2:** Run → FAIL. **Step 3:** Implement. **Step 4:** Run → pass.
- [ ] **Step 5:** Commit `feat: parent gate`.

### Task 8: Voice, Nav, Momo, BigButton, Home screen

**Files:**
- Create: `scripts/core/voice.gd`, `scripts/core/nav.gd`, `scenes/components/momo.tscn/.gd`, `scenes/components/big_button.tscn/.gd`, `scenes/home/home.tscn/.gd`
- Modify: `project.godot` (autoloads `Voice`, `Nav`, `Progress`, `TimerService`; main scene)

**Interfaces:**
- `Voice`: `play(key: String) -> void` (stops current, plays new; missing file → silent, `push_warning`), `play_sfx(name: String)`, `stop()`, `signal finished`.
- `Nav`: `go(scene_path: String, params := {}) -> void`, `params() -> Dictionary`, `back() -> void` (history stack); `go` ignores calls while a transition (0.25 s fade) is running — toddler double taps.
- `Momo` (Control): `idle()`, `talk()` (bob while `Voice` plays), `dance()`, `scratch_head()`, `wear(outfit_id)`; tapping Momo emits `signal tapped`.
- `BigButton` (TextureButton, min 200×200 px): exports `voice_key`, `icon`; on press plays `voice_key`, scale-bounce tween, emits `pressed_after_voice` immediately (do not wait for voice to finish).
- Home: grid of 8 category BigButtons (icon = `icon_item` image or color circle / number), locked category shows lock and plays `cat_<id>` + "boop" only; album button; small parent button (top-right, 80×80); Momo bottom-left says `hello` on first open per app start.

- [ ] **Step 1:** Build components and Home.
- [ ] **Step 2:** Run in editor (F5): Home shows 8 categories, numbers_2 locked, each tap speaks, Momo greets. Rapid double tap on a category opens it once.
- [ ] **Step 3:** Run unit tests — still all pass.
- [ ] **Step 4:** Commit `feat: home screen, Momo and navigation`.

### Task 9: Category screen + Learn

**Files:**
- Create: `scenes/category/category.tscn/.gd`, `scenes/learn/learn.tscn/.gd`, `scenes/components/item_view.tscn/.gd`

**Interfaces:**
- `ItemView` (Control): `show_item(item: Dictionary)` — emoji → SVG texture; color → big rounded circle in that color; number → large numeral + `number` small apple icons in rows of 5.
- Category: Learn + Play BigButtons (`learn`, `play` voice keys), back arrow, Momo.
- Learn: one ItemView center, plays `this_<id>` on show; tap item replays; left/right arrow buttons; no auto-advance; last item → right arrow returns to the first.

- [ ] **Step 1:** Build. **Step 2:** Run in editor: walk through colors, numbers_1 (count audio matches apples), reptiles; confirm nothing advances by itself.
- [ ] **Step 3:** Commit `feat: category and learn screens`.

### Task 10: Play + Reward screens

**Files:**
- Create: `scenes/play/play.tscn/.gd`, `scenes/reward/reward.tscn/.gd`, `scenes/components/confetti.tscn` (CPUParticles2D — not GPU, for Compatibility renderer on 2GB phone)

**Interfaces:**
- Consumes: `RoundSession`, `Progress.award_sticker`, `Voice`, `Momo`, `ItemView`.
- Play: on each question plays `where_<target>`; tap Momo replays. Answer handling: `"correct"` → option grows, confetti, `clap`, random of great_job/well_done/yay, Momo dances, after 1.2 s `unlock()` and next; `"wrong"` → wiggle tween (±12 px, 0.3 s), Momo scratches head, `try_again`; `"ignored"` → nothing. Small progress dots (5) at top. Finished → `Nav.go(reward, {category, round_token})` where `round_token = Time.get_ticks_usec()` created once per round.
- Reward: calls `award_sticker`; sticker flies into album icon with `got_sticker`; if outfit unlocked → Momo wears it + `new_outfit`; full page → Momo dance + stars only. Tap anywhere → category screen.

- [ ] **Step 1:** Build. **Step 2:** Run in editor: play 3 rounds in colors (options go 2,2,2 then 3 on round 4), mash taps during celebration (no skip, one sticker per round), wrong taps never penalise.
- [ ] **Step 3:** Commit `feat: play and reward screens`.

### Task 11: Sticker album

**Files:**
- Create: `scenes/album/album.tscn/.gd`

- Pages = categories; horizontal swipe + arrows; slot grid shows grey silhouette (item image with modulate black 15% alpha) for missing, full colour for owned; tapping an owned sticker plays `name_<id>`; page header = category icon + speaks `cat_<id>`; complete page shows the outfit badge; tapping it makes Momo wear it (`set_worn_outfit`).

- [ ] **Step 1:** Build. **Step 2:** Run with a save that has partial + one full page; check silhouettes, sounds, outfit switching persists after restart.
- [ ] **Step 3:** Commit `feat: sticker album`.

### Task 12: Parents area, time-up screen, back button

**Files:**
- Create: `scenes/parents/parents.tscn/.gd`, `scenes/time_up/time_up.tscn/.gd`
- Modify: `scripts/core/nav.gd` (back button), `scripts/core/timer_service.gd` (hook `time_up` → `Nav.go(time_up)`)

- Parents: ParentGate first (wrong → new question, no lockout); then limit buttons Off/10/15/20/30 (current highlighted), "10 more minutes today" (+10 bonus), "Reset progress" with a second confirm, credits text from `CREDITS.md`.
- Time-up: calm background, Momo waves, plays `bye` once; only a small parent button → ParentGate → Parents.
- Back button (`NOTIFICATION_WM_GO_BACK_REQUEST`, set `application/config/quit_on_go_back=false`): Home → ignore; Time-up → ignore; others → `Nav.back()`.

- [ ] **Step 1:** Build. **Step 2:** Manual checks in editor with limit set to 1 min via a debug override: time-up appears mid-Play; back/escape does not leave time-up; gate + "10 more minutes" returns to Home; app minimise pauses timer (check `used_sec` in save before/after).
- [ ] **Step 3:** Run unit tests — all pass.
- [ ] **Step 4:** Commit `feat: parents area and time limit`.

### Task 13: Android build and phone test

**Files:**
- Create: `export_presets.cfg`, `README.md` (build section)

- [ ] **Step 1:** Configure Godot editor settings: Java SDK path (JDK 17), Android SDK path; debug keystore auto-generated.
- [ ] **Step 2:** Android preset: arm64-v8a + armeabi-v7a (Infinix may be 32-bit), min SDK 24, landscape, permissions: none (INTERNET unchecked), package `com.hamza.learnwithmomo`, name "Learn with Momo", icon from `momo.svg` (192 px), ETC2/ASTC textures, exclude `tools/*, tests/*, docs/*, build/*, addons/gut/*`.
- [ ] **Step 3:** Export: `godot --headless --path . --export-debug "Android" build/learn-with-momo.apk`. Expected: file exists, size < 50 MB.
- [ ] **Step 4:** User installs on Infinix (USB `adb install` or copy file). Checklist: cold start < 5 s, no stutter in confetti, voice clear, landscape locked, no internet permission shown in app info.
- [ ] **Step 5:** Then on Tecno. Commit `build: android export preset`. Release build/keystore is out of scope (sideload only).

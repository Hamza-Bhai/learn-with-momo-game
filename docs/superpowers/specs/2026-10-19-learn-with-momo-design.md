# Learn with Momo — Design

Date: 2026-10-19
Status: Draft, waiting for approval

## 1. Purpose (Why)

A 3-year-old spends a lot of time watching short videos full of poor language, and it is affecting how she speaks. The goal is an Android game that:

- lets her hear and repeat **clear English**
- **teaches things** along the way (colors, counting, animals, flowers, body parts...)
- is fun enough that she plays it instead of watching shorts
- a **parent can sit with her** and teach through

Success means: after 2-3 months the child recognises and says the English names of these things.

## 2. Who will use it

- **Child (3 years old):** cannot read, only taps, gets upset quickly when losing.
- **Parent:** sits with her and sets the time limit.
- **Phones:** Infinix (2GB RAM, 16GB) and Tecno Camon (6GB RAM, 128GB). The game must run smoothly on the weaker one (Infinix).

## 3. Goals

1. Two modes in every category: **Learn** (picture + clear English name) and **Play** ("Where is the turtle?").
2. Starting categories:
   - Colors (~10)
   - Numbers / counting 1–20 (first 1–10, then 11–20)
   - Animals: farm and jungle (~10)
   - Sea animals (~8)
   - Reptiles (~6)
   - Flowers (~6)
   - Body parts (~10)
3. Adding a new category or item is **data only** (picture + voice + one entry), with no code changes.
4. A friendly character, **Momo the monkey**: talks, dances, encourages.
5. **Reward:** every Play round won = 1 sticker. Each category has its own page in the sticker album. When a page is full, Momo gets a new hat/outfit.
6. **Parents area** (behind a parent gate): time limit (Off / 10 / 15 / 20 / 30 min), progress reset.
7. Fully **offline**. No internet permission at all.

## 4. Non-goals (not in the first version)

- Multiplication tables: at age 5-6.
- Urdu content.
- Publishing on the Play Store. For now the APK is installed directly on the phone.
- Profiles for more than one child.
- Online features, login, cloud sync.
- A "touch the cartoon child to show the body part" mode. Body parts follow the same pattern as the other categories first. That mode comes later.

## 5. Anti-goals (if any of these happen the game has failed, even if it works)

- Any ads, in-app purchases, or external links.
- Punishment for wrong answers: buzzer, red X, or a crying Momo. Only "Try again!" and a gentle wiggle.
- A shorts-like feed that plays by itself and never ends.
- Very fast, flashy, noisy screens that overstimulate the child.
- Any screen where the child has to read.
- Freezing or opening slowly on a 2GB phone.

## 6. How it will be built (decisions)

| Topic | Decision | Decided by |
|---|---|---|
| Engine | Godot 4 (latest stable 4.x), GDScript | User agreed |
| Platform | Android APK | User |
| Renderer | Compatibility (GLES3), for weak phones | Claude |
| Orientation | Landscape | Claude |
| Voice | Pre-generated clear, friendly English voice (Piper TTS, offline neural voice), OGG files inside the game | User left it to Claude |
| Pictures | Twemoji (CC-BY 4.0) cartoon pictures, as PNG, all in one style. Credits screen in the parents area | Claude |
| Data | One JSON file per category: items (id, name, picture, voice files) | Claude |
| Save | `user://save.json` (stickers, settings) | Claude |
| APK size | Target under 50 MB | Claude |

## 7. Screens and flow

1. **Home:** category buttons with big pictures (each button shows one picture of the category, and tapping it says the category name). An album button and a small parents button in the corners. Momo stands in a corner.
2. **Category screen:** two big buttons: **Learn** (eye/book icon) and **Play** (play icon). Tapping also says "Learn" / "Play".
3. **Learn:** one big picture + voice: "This is a **turtle**." Tap the picture = hear it again. Big left/right arrows go to the next/previous item. Momo moves slightly with the name. It never moves on by itself (anti-goal: auto-feed).
   - Colors: a big circle of the color / a colored object.
   - Numbers: a big number + that many objects ("This is **three**. One, two, three!").
4. **Play round:** 5 questions. Each question shows 2 pictures (slowly rising to 3 as rounds are won). Voice: "Where is the **turtle**?"
   - Right tap: the picture grows, confetti, clapping, Momo dances, "Great job!" Then the next question.
   - Wrong tap: the picture wiggles, Momo scratches his head, "Try again!" The same question stays. No score is lost.
   - Tap Momo to hear the question again.
   - End of round = sticker reward screen (the sticker flies into the album), then the category screen.
5. **Sticker album:** one page per category, empty sticker slots (outlines). Earned stickers are in color. Full page = Momo gets a new item (hat, glasses, crown...) and shows it off.
6. **Parents area:** parent gate (a grown-up question, such as "Tap the number: seven plus five" choosing the right number), then:
   - Time limit: Off / 10 / 15 / 20 / 30 minutes
   - Progress reset (with confirmation)
   - Credits / licenses
7. **Time up:** when the limit is reached, Momo says "Bye bye! See you tomorrow!" and a calm screen appears. It can only be unlocked through the parent gate. The timer only runs while the game is on screen. It is **today's total**: closing and reopening the app continues from the same point, and it **resets to zero at midnight**. Parents can open the gate to give "10 more minutes" or change the limit. (Claude's decision.)

## 8. Content list (first version)

- **Colors:** red, blue, yellow, green, orange, purple, pink, black, white, brown
- **Numbers:** one to twenty
- **Animals:** cat, dog, cow, horse, sheep, goat, chicken, lion, elephant, monkey
- **Sea animals:** fish, whale, dolphin, octopus, shark, crab, turtle (sea), jellyfish
- **Reptiles:** snake, lizard, crocodile, turtle, dinosaur (really an old relative of reptiles, but kids love it), chameleon (if a picture exists, otherwise a lizard in another color)
- **Flowers:** rose, sunflower, tulip, lotus, hibiscus, cherry blossom
- **Body parts:** eye, ear, nose, mouth, tooth, tongue, hand, foot, leg, hair (if no picture exists, a face with hair)

Builder's job: find each item's picture in Twemoji; drop any that cannot be found or use a close match, and note it here.

## 9. Voice (phrases)

Every item gets full sentences generated as separate files (so the tone sounds natural):
- `this_is_<id>` → "This is a turtle." (colors: "This is red.", numbers: "This is three. One, two, three!")
- `where_is_<id>` → "Where is the turtle?" (colors: "Where is red?", numbers: "Where is number three?")
- `name_<id>` → "Turtle!"

Common phrases: "Great job!", "Well done!", "Yay!", "Try again!", "You got a sticker!", "Learn", "Play", the category names, "Bye bye! See you tomorrow!"
Also: light sound effects such as clapping, pop and confetti (CC0).

Speech should be slightly slower than normal.

## 10. Testing

- GDScript unit tests (GUT) for the logic (building rounds, awarding stickers, completing the album, timer, save/load).
- Run every build in the Godot editor on Windows.
- Real test: install the APK on the Infinix 2GB phone: startup time, smoothness, voice.
- Final test: the child and parent play it; wherever the child gets stuck, the design changes.

## 11. Left to the builder

- Exact colors and animation details, confetti style
- Momo's actual design (start from Twemoji 🐵, tween animations)
- Folder structure, scene structure
- Which items get paired in a question (two look-alike items should not appear together)

## 12. Small decisions Claude made (for the user to check)

- The game is named **"Learn with Momo"** and the monkey is named **Momo**. The user can change this.
- Wrong options (distractors) in Play come from the same category.
- Each round won gives the **next unearned** sticker of that category (each item = one sticker). If the turtle is in both sea animals and reptiles, those are two separate stickers.
- Play keeps working after a page is full: instead of a sticker, Momo dances and stars appear.
- The project folder `D:\Projects\Android-Games` becomes a git repo, so every step is saved.

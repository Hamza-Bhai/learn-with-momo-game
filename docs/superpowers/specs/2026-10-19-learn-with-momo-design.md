# Learn with Momo — Design

Date: 2026-10-19
Status: Draft, waiting for approval

## 1. Maqsad (Why)

Meri 3 saal ki beti mobile par bohot shorts dekhti hai jin mein ghalat zabaan hoti hai, aur us ki zabaan kharab ho rahi hai. Mujhe ek Android game chahiye jo:

- usay **saaf English** sunaye aur bulwaye
- us ke saath saath **cheezein sikhaye** (colors, ginti, janwar, phool, body parts...)
- itni mazedaar ho ke woh shorts ki jagah yeh khele
- jis par **ammi saath baith kar** usay seekhayein

Kamyabi ka matlab: 2-3 mahine baad bachi in cheezon ke English naam pehchanti aur bolti ho.

## 2. Kaun use karega

- **Bachi (3 saal):** parh nahi sakti, sirf tap karti hai, haarne par jaldi ruthti hai.
- **Ammi:** saath baithti hain, time limit set karti hain.
- **Phones:** Infinix (2GB RAM, 16GB) aur Tecno Camon (6GB RAM, 128GB). Game ko kamzor wale (Infinix) par smooth chalna chahiye.

## 3. Goals

1. Har category mein do modes: **Seekho** (tasveer + saaf English naam) aur **Khelo** ("Where is the turtle?").
2. Shuru ki categories:
   - Colors (~10)
   - Numbers / ginti 1–20 (pehle 1–10, phir 11–20)
   - Animals: ghar aur jungle (~10)
   - Sea animals (~8)
   - Reptiles (~6)
   - Flowers (~6)
   - Body parts (~10)
3. Nayi category ya nayi cheez jorna **sirf data** ka kaam ho (tasveer + awaaz + ek entry), code badle baghair.
4. Dost character **Momo bandar**: bolta, naachta, hausla deta hai.
5. **Reward:** har jeeta hua Khelo round = 1 sticker. Har category ka sticker album mein alag page. Page poora hone par Momo ko nayi topi/kapra milta hai.
6. **Parents area** (parent gate ke peeche): time limit (Off / 10 / 15 / 20 / 30 min), progress reset.
7. Poori tarah **offline**. Internet permission hi na ho.

## 4. Non-goals (pehle version mein nahi)

- Pahaaray (multiplication tables): 5-6 saal ki umar par.
- Urdu content.
- Play Store par daalna. Abhi sirf APK seedha phone mein install hogi.
- Ek se zyada bachon ke profiles.
- Online, login, cloud sync.
- Body parts ka "cartoon bachay ko chhoo kar batao" wala mode. Pehle body parts bhi baqi categories wale pattern par chalenge. Yeh mode baad mein.

## 5. Anti-goals (yeh hua to game nakaam hai, chahe chal rahi ho)

- Koi ads, in-app purchase, ya bahar ka link.
- Ghalat jawab par saza, buzzer, laal X, ya rone wala Momo. Sirf "Try again!" aur halki si wiggle.
- Shorts jaisa khud-ba-khud chalne wala, kabhi khatam na hone wala feed.
- Bohot tez, chamakti, shor wali screens jo bachay ko overstimulate karein.
- Koi bhi screen jahan bachi ko parhna pare.
- 2GB phone par atakna ya dheere khulna.

## 6. Kaise banegi (faislay)

| Cheez | Faisla | Kis ka faisla |
|---|---|---|
| Engine | Godot 4 (latest stable 4.x), GDScript | User ne mana |
| Platform | Android APK | User |
| Renderer | Compatibility (GLES3), kamzor phones ke liye | Claude |
| Orientation | Landscape | Claude |
| Awaaz | Pehle se generate ki hui saaf, khushgawar English awaaz (Piper TTS, offline neural voice), OGG files game ke andar | User ne Claude par chhora |
| Tasveerein | Twemoji (CC-BY 4.0) cartoon tasveerein, PNG mein, sab ek hi style ki. Credits screen parents area mein | Claude |
| Data | Har category ki ek JSON file: items (id, naam, tasveer, awaaz files) | Claude |
| Save | `user://save.json` (stickers, settings) | Claude |
| APK size | Target 50 MB se kam | Claude |

## 7. Screens aur flow

1. **Home:** bari tasveeron wale category buttons (har button par category ki ek tasveer, aur tap par category ka naam bola jaye). Kone mein album ka button aur chhota sa parents button. Momo kone mein khara hai.
2. **Category screen:** do bare buttons: **Seekho** (aankh/kitaab icon) aur **Khelo** (play icon). Tap par awaaz bhi bataye "Learn" / "Play".
3. **Seekho:** ek bari tasveer + awaaz: "This is a **turtle**." Tasveer par tap = dobara sune. Bare left/right arrows se agli/pichli cheez. Momo naam ke saath halka sa hilta hai. Khud se aage nahi chalta (anti-goal: auto-feed).
   - Colors: rang ka bara gola / rangeen cheez.
   - Numbers: bara number + utni hi cheezein ("This is **three**. One, two, three!").
4. **Khelo round:** 5 sawal. Har sawal par 2 tasveerein (round jeetne ke saath dheere dheere 3 tak). Awaaz: "Where is the **turtle**?"
   - Sahi tap: tasveer bari ho, confetti, taali, Momo naachay, "Great job!" Phir agla sawal.
   - Ghalat tap: tasveer wiggle kare, Momo sar khujaye, "Try again!" Wohi sawal rehta hai. Koi score nahi katta.
   - Sawal dobara sunne ke liye Momo par tap.
   - Round khatam = sticker milne ki screen (sticker ura kar album mein jata dikhe), phir category screen.
5. **Sticker album:** har category ka ek page, sticker ki khaali jagahen (outline). Mile hue stickers rangeen. Page poora = Momo ko nayi cheez (topi, chashma, taj...) aur Momo usay pehan kar dikhata hai.
6. **Parents area:** parent gate (bari umar wala sawal, jaise "Tap the number: seven plus five" mein se sahi number), phir:
   - Time limit: Off / 10 / 15 / 20 / 30 minute
   - Progress reset (confirm ke saath)
   - Credits / licenses
7. **Time khatam:** jab limit poori ho, Momo "Bye bye! See you tomorrow!" kahe aur ek aaram wali screen aaye. Sirf parent gate se khul sakti hai. Timer sirf tab chalta hai jab game screen par khuli ho. Yeh **aaj ka total** hota hai: app band karke dobara kholne par bhi wahin se chalta hai, aur **raat 12 baje khud zero** ho jata hai. Parents gate khol kar "10 minute aur" de sakte hain ya limit badal sakte hain. (Claude ka faisla.)

## 8. Content list (pehla version)

- **Colors:** red, blue, yellow, green, orange, purple, pink, black, white, brown
- **Numbers:** one to twenty
- **Animals:** cat, dog, cow, horse, sheep, goat, chicken, lion, elephant, monkey
- **Sea animals:** fish, whale, dolphin, octopus, shark, crab, turtle (sea), jellyfish
- **Reptiles:** snake, lizard, crocodile, turtle, dinosaur (asal mein reptile ka purana rishtedaar, bachon ko pasand), chameleon (agar tasveer mil jaye, warna lizard ka doosra rang)
- **Flowers:** rose, sunflower, tulip, lotus, hibiscus, cherry blossom
- **Body parts:** eye, ear, nose, mouth, tooth, tongue, hand, foot, leg, hair (agar tasveer na mile to baal wala chehra)

Builder ka kaam: har item ki tasveer Twemoji mein dhoondna; jo na mile use list se hata dena ya mila julta lena, aur yahan likh dena.

## 9. Awaaz (phrases)

Har item ke liye poore jumlay alag file mein generate hon (taake lehja qudrati lagay):
- `this_is_<id>` → "This is a turtle." (colors: "This is red.", numbers: "This is three. One, two, three!")
- `where_is_<id>` → "Where is the turtle?" (colors: "Where is red?", numbers: "Where is number three?")
- `name_<id>` → "Turtle!"

Aam jumlay: "Great job!", "Well done!", "Yay!", "Try again!", "You got a sticker!", "Learn", "Play", category ke naam, "Bye bye! See you tomorrow!"
Saath mein: taali, pop, confetti jaisi halki sound effects (CC0).

Awaaz ki raftaar aam se thori dheemi rakhi jaye.

## 10. Testing

- Logic (round banana, sticker dena, album poora hona, timer, save/load) ke liye GDScript unit tests (GUT).
- Har build Windows par Godot editor mein chala kar dekhna.
- Asal test: APK Infinix 2GB phone par install karke: khulne ka waqt, smooth chalna, awaaz.
- Aakhri test: bachi aur ammi khelein; jahan bachi atke, wahan design badle.

## 11. Builder par chhora hua

- Sahi rang aur animations ki tafseel, confetti ka andaz
- Momo ka asal design (Twemoji 🐵 se shuru, tween animations)
- Folder structure, scene structure
- Kis item ko kis sawal mein jodi banaye (ek jaise dikhne wale do items ek saath na aayein)

## 12. Chhote faislay jo Claude ne khud kiye (user check kar le)

- Game ka naam **"Learn with Momo"** aur bandar ka naam **Momo**. User badal sakta hai.
- Khelo mein ghalat options (distractors) usi category se aate hain.
- Har jeeta round us category ka **agla na mila hua** sticker deta hai (har item = ek sticker). Turtle sea aur reptiles dono mein ho to do alag stickers hain.
- Page poora hone ke baad bhi Khelo chalta rahe: sticker ki jagah Momo ka dance aur stars.
- Project folder `D:\Projects\Android-Games` mein git repo banega, taake har qadam save rahe.

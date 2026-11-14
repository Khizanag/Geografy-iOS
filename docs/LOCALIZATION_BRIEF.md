# Translation brief

Read this before translating Geografy's String Catalogs. It applies to every language; Georgian (`ka`) is the one shipped today.

## The app

Geografy is a geography learning app for iPhone. People explore the world's countries on a map and in lists, play quizzes on flags, capitals, and borders, keep a travel journal, and earn XP, levels, and achievements. Example: "Name the country" over a flag, with four answers to pick from.

## Tone

- Friendly, short, and plain: the copy reads like a helpful game, not a textbook.
- Address the person informally, with the same form the existing translations use (Georgian: შენ, never თქვენ).
- Imperatives for buttons ("Save", "Start"), noun phrases for titles and headers.
- Accessibility hints describe what a control does in the third person, as the English does ("Opens the flag full screen"): Georgian uses the present tense verb, such as "ხსნის დროშას სრულ ეკრანზე".

## Length

Stay close to the English length. Most strings are buttons, headers, and VoiceOver labels.

## Never translate

- The app name, Geografy.
- XP, and organization acronyms such as UN, EU, NATO, and UNESCO.
- Apple brand names: iCloud, Game Center, Siri.

## Placeholders

- Keep every placeholder: `%@`, `%lld`, `%%`, and their count. `%@` is text (a country, a name, a date, a duration); `%lld` is a whole number.
- With two or more placeholders, reorder freely using positional forms: `%1$@`, `%2$lld`, where the digit is the argument's position in the English, counting `%@` and `%lld` together.
- Keep Markdown such as `**bold**` and line breaks (`\n`).

## Plurals

Georgian nouns stay singular after a number ("%lld ქვეყანა", not "ქვეყნები"), so one string covers every count.

## Glossary

Reuse the wording already in the catalogs for the app's terms, so a term reads the same on every screen:

| English | Georgian |
|---|---|
| Favorites | რჩეულები |
| Country, Countries | ქვეყანა, ქვეყნები |
| Capital | დედაქალაქი |
| Quiz | ვიქტორინა |
| Flag | დროშა |
| Level | დონე |
| Map | რუკა |
| Travel Journal | მოგზაურობის დღიური |
| Achievements | მიღწევები |
| Flashcards | ფლეშბარათები |
| Explore | აღმოაჩინე |

## Output

One JSON object keyed by the exact English key, with the translation as each value. UTF-8, every key included.

## After merging translations

SwiftUI looks most package text up in the app's own catalog, so run `python3 scripts/merge_package_strings.py` after any translation pass and commit `Geografy/Resource/Localizable.xcstrings` with the package catalogs. Without it, package screens stay in English.

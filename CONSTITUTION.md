# Geografy constitution

What Geografy adds to the shared [iOS constitution](../iOS-Constitution/CONSTITUTION.md), and where it departs from it. The shared articles bind everything not named here. [`.instructions/adaptivity.md`](./.instructions/adaptivity.md) narrows Part IV with a check for each setting.

## Identity marks

Article 6 keeps the accent rare and lets an app name the few marks its identity rests on. Geografy's identity is its games and its map:

- **Each game's own colour:** its hub tile's icon, its setup header and fact pills, and its guide. Quiz is blue, Map Puzzle purple, Pin Drop orange, and so on, so a game is known by its colour wherever it appears.
- **The map:** country fills, continent palettes, and the selected country's highlight. These are data palettes (article 5).

Beyond what article 6 already allows, the accent marks:

- **The reader's progress:** a session's progress bar, a step indicator, and the Learning Path's modules and lessons.
- **The brand:** the map's loading globe, the ambient background, the profile header's ring, a result's share card, and the New badge.
- **A chart's own series:** the line, area, and bars of a single-series chart.
- **A chosen item's edge:** the check, border, or fill that marks the selected tile, chip, or index letter, as a picker's checkmark does.

## Articles of its own

### Article 101: green is right, red is wrong

Green means a right answer, something done, or success; red means a wrong answer, an error, or a destructive action. Neither is ever decoration, and both always come with a glyph or a word (article 8).

### Article 102: every game opens on its setup

Every game has one way in: its tile opens its setup page, never the game itself. The setup shows the game's header, its choices, and Start in the bottom bar, and its guide opens by itself the first time and from the toolbar after that. A variant of a game, such as a quiz type, is a choice on that game's setup, never a tile of its own. A fact in the setup's header that the player can change is a button that scrolls to its setting.

### Article 103: every game answers the same way

A game that asks a question with a few answers draws them with the shared answer list and plays the shared feedback: the same glass capsules, the same right and wrong marks, sound, haptic, and spoken result. A game is left with the close button and a Give Up confirmation, and moves on after an answer as the player's Next Question setting says.

### Article 104: an odd tile spans its row

In a two-column grid of tiles, a last tile alone on its row takes the full width, so a section never ends in a gap.

### Article 105: a card that acts takes the press style

A card, tile, or row that is itself the button takes `PressButtonStyle`: it dims and settles while pressed, taps lightly at half strength, lifts under a pointer, and fades when disabled. A standalone button is glass (article 3), never this style around a hand-drawn fill.

### Article 106: every press is felt

At the owner's word, a press on a button or a card is a change of state that is felt: `GlassButton` taps lightly on every press and `PressButtonStyle` at half strength, each through `.sensoryFeedback` on the button itself (article 23). A screen never adds a tap of its own to a press; it adds a haptic only for what the press changed, such as a right answer, a toggled favorite, or a choice among options.

### Article 107: every game plays in Local Play

At the owner's word, every game the app has can be played against a nearby phone, and a new game ships with its Local Play mode. It plays through the game's own screen with a `LocalMatch`: the host picks and sends what both phones play, each round is reported, the other player shows in the shared opponent chip, and the match ends in the shared result screen. A race ends when the first player finishes; the other games once both have.

## Exceptions

### Articles 2 and 4: the zoom viewer covers the screen with a blur

The viewer that enlarges a flag or an organisation's logo is a full-screen cover over a thin material, so the image is seen over a blur of the screen it came from. It turns solid under Reduce Transparency. It is a media viewer, not a control and not a sheet that edits or picks.

### Article 3: sized glass circles

The pronounce button beside a name and the swap button between two picked items keep a fixed diameter that matches the text or the circle beside them, so they draw interactive system glass on their own label (`.glassEffect(.regular.interactive(), in: .circle)`) rather than taking `.buttonStyle(.glass)`, whose padding would change their size. The glass is still the system's.

### Article 19: English only until launch preparation

The app ships in English only until launch preparation begins, at the owner's word on 2026-11-16. Every string still goes through the String Catalog, so adding a language is translation, not code.

### Parked platforms

The tvOS and Mac Catalyst targets are parked at the owner's word and are not held to the constitution until they are reopened.

## Not yet conforming

Open work from the adoption audit on 2026-11-24, each with what it takes. Remove an entry when it lands.

- **Article 5, tokens.** About 140 raw colours in about 60 files, some of them data palettes. Each goes to a token or to the one palette file.
- **Article 19, in-app language.** About 85 `String(localized:)` calls read the launch language. Needed once a second language ships; until then the exception above holds.
- **Article 12, item actions.** Card rows have the shared long press and swipe in `RowListMenu`: a preview, Open, Copy, Share, and Remove, with a swipe to remove. The recents of Distance Calculator, Compare, and Currency Converter use it. Other lists, such as countries, favorites, collections, and the journal, still offer long presses and swipes screen by screen, or none.
- **Article 18, the audit.** No UI test runs `performAccessibilityAudit()`. The test lands with the fixes, so it never sits in the suite failing.

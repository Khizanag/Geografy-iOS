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

## Exceptions

### Articles 2 and 4: the zoom viewer covers the screen with a blur

The viewer that enlarges a flag or an organisation's logo is a full-screen cover over a thin material, so the image is seen over a blur of the screen it came from. It turns solid under Reduce Transparency. It is a media viewer, not a control and not a sheet that edits or picks.

### Article 19: English only until launch preparation

The app ships in English only until launch preparation begins, at the owner's word on 2026-11-16. Every string still goes through the String Catalog, so adding a language is translation, not code.

### Parked platforms

The tvOS and Mac Catalyst targets are parked at the owner's word and are not held to the constitution until they are reopened.

## Not yet conforming

Open work from the adoption audit on 2026-11-24, each with what it takes. Remove an entry when it lands.

- **Article 23, haptics.** About 160 calls to `HapticsService` in 68 files, and `PressButtonStyle` plays its own impact. Moving to `.sensoryFeedback(_:trigger:)` on the view whose state changed, with the Haptics setting read from the environment, replaces the service.
- **Article 3, buttons.** `PressButtonStyle` stands in for system buttons in about 70 files, and about 25 files draw glass by hand with `.glassEffect`. The map's country banner draws its Open capsule by hand.
- **Article 5, tokens.** About 140 raw colours in about 60 files, some of them data palettes. Each goes to a token or to the one palette file.
- **Article 19, in-app language.** About 85 `String(localized:)` calls read the launch language. Needed once a second language ships; until then the exception above holds.
- **Article 12, item actions.** Lists offer long presses and swipes screen by screen, in 6 files, with no shared modifier per kind of item, and most lists offer none.
- **Article 18, the audit.** No UI test runs `performAccessibilityAudit()`. The test lands with the fixes, so it never sits in the suite failing.

# App Store Connect checklist

What Geografy needs outside the repo before its first submission. The code side is done: Release builds use the identifiers below, and both targets ship a privacy manifest.

## 1. Identifiers

Register these in Certificates, Identifiers & Profiles, then make App Store distribution profiles for the two App IDs.

| Identifier | Kind | Capabilities |
|---|---|---|
| `com.khizanag.geografy` | App ID | Sign in with Apple, Game Center, App Groups |
| `com.khizanag.geografy.widgets` | App ID | App Groups |
| `group.com.khizanag.geografy` | App Group | Assigned to both App IDs |

Debug builds keep `com.khizanag.geografy.dev`, `com.khizanag.geografy.dev.widgets`, and `group.com.khizanag.geografy.dev`. The suffix comes from the `GEOGRAFY_ID_SUFFIX` project setting.

## 2. App record

- [ ] Confirm App Store ID `6743292498` belongs to `com.khizanag.geografy`. The store link in Settings uses it and returns 404 until the app is live, which is expected.
- [ ] If the record doesn't exist or uses another bundle ID, create it and update `SettingsURLs.appStore`.

## 3. Game Center

Enable Game Center on the app record, then create each item with exactly these IDs.

### Leaderboards

All are classic, all-time leaderboards.

| ID | Name | Score format | Order |
|---|---|---|---|
| `com.khizanag.geografy.leaderboard.totalxp` | Total XP | Integer | High to low |
| `com.khizanag.geografy.leaderboard.longeststreak` | Longest Streak | Integer (days) | High to low |
| `com.khizanag.geografy.leaderboard.quizhighscore` | Quiz High Score | Integer (percent) | High to low |
| `com.khizanag.geografy.leaderboard.countriesvisited` | Countries Visited | Integer | High to low |
| `com.khizanag.geografy.leaderboard.dailychallengeswon` | Daily Challenges | Integer | High to low |
| `com.khizanag.geografy.leaderboard.speedrun.world` | Speed Run: World | Elapsed time, tenths of a second | Low to high |
| `com.khizanag.geografy.leaderboard.speedrun.africa` | Speed Run: Africa | Elapsed time, tenths of a second | Low to high |
| `com.khizanag.geografy.leaderboard.speedrun.asia` | Speed Run: Asia | Elapsed time, tenths of a second | Low to high |
| `com.khizanag.geografy.leaderboard.speedrun.europe` | Speed Run: Europe | Elapsed time, tenths of a second | Low to high |
| `com.khizanag.geografy.leaderboard.speedrun.northamerica` | Speed Run: North America | Elapsed time, tenths of a second | Low to high |
| `com.khizanag.geografy.leaderboard.speedrun.southamerica` | Speed Run: South America | Elapsed time, tenths of a second | Low to high |
| `com.khizanag.geografy.leaderboard.speedrun.oceania` | Speed Run: Oceania | Elapsed time, tenths of a second | Low to high |

Quiz High Score takes the accuracy percent of any quiz or flashcard session, so it tops out at 100 and most players will tie there. Decide whether to keep it before creating it.

### Achievements

22 of the app's 37 achievements report to Game Center. The rest stay in-app only. Points are not set in code; Game Center allows at most 1,000 in total.

| ID | Title | Description |
|---|---|---|
| `geografy.achievement.first_steps` | Curious Wanderer | Explore 5 countries on the map |
| `geografy.achievement.continental_explorer` | Continental Explorer | Explore 10 countries |
| `geografy.achievement.world_traveler` | World Traveler | Explore 50 countries |
| `geografy.achievement.globe_trotter` | Globe Trotter | Explore 100 countries |
| `geografy.achievement.master_explorer` | Master Explorer | Explore all 195 countries |
| `geografy.achievement.first_quiz` | First Quiz | Complete your first quiz |
| `geografy.achievement.quiz_fanatic` | Quiz Fanatic | Complete 10 quizzes |
| `geografy.achievement.quiz_legend` | Quiz Legend | Complete 100 quizzes |
| `geografy.achievement.all_types` | Polymath | Complete all quiz types at least once |
| `geografy.achievement.getting_started` | Getting Started | Log in 3 days in a row |
| `geografy.achievement.week_warrior` | Week Warrior | Log in 7 days in a row |
| `geografy.achievement.monthly_champion` | Monthly Champion | Log in 30 days in a row |
| `geografy.achievement.dedicated_scholar` | Dedicated Scholar | Log in 100 days in a row |
| `geografy.achievement.first_stamp` | First Stamp | Mark your first visited country |
| `geografy.achievement.frequent_flyer` | Frequent Flyer | Visit 10 countries |
| `geografy.achievement.world_adventurer` | World Adventurer | Visit 50 countries |
| `geografy.achievement.bucket_list` | Bucket List | Add 5 want-to-visit countries |
| `geografy.achievement.flag_collector` | Flag Collector | Complete 5 flag quizzes |
| `geografy.achievement.capital_expert` | Capital Expert | Complete 5 capital quizzes |
| `geografy.achievement.org_scholar` | Org Scholar | Explore all organizations |
| `geografy.achievement.speed_demon` | Speed Demon | Finish a Hard quiz in under 60 seconds |
| `geografy.achievement.perfect_score` | Flawless | Get 100% on any quiz |

## 4. Privacy

- [ ] **App Privacy: Data Not Collected.** Geografy has no server and no analytics. A Sign in with Apple profile stays on the device; Game Center is Apple's own service. The only network requests fetch exchange rates (`open.er-api.com`), World Bank data (`api.worldbank.org`), and Wikipedia images, and send nothing about the player.
- [ ] **Privacy policy and terms pages.** Settings links to `https://khizanag.github.io/privacy/geografy` and `/terms/geografy`, published from the site repo.

## 5. Review notes

> Geografy is a geography learning app that works fully offline. No account is needed: a guest can use every feature. Sign in with Apple only keeps progress under a named profile on this device. Game Center leaderboards and achievements are optional. There are no purchases.

## 6. Metadata

- [ ] Screenshots for 6.9-inch iPhone and 13-inch iPad.
- [ ] Name, subtitle, description, keywords, and support URL.
- [ ] Age rating questionnaire.

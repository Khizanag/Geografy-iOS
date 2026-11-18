# Geografy iOS — TODO

Open tasks only. Completed work is in git history; the plan for the next phases is in the [2026-11-17 audit](audit/2026-11-17-app-audit.md).

## Features

- [ ] Physical map type with terrain and elevation
- [ ] Reorder quiz: drag countries into order by population or area
- [ ] Game Center friends

## Product decisions

- [ ] Monetization: whether to charge, and how (nothing is integrated until decided)
- [ ] Mac Catalyst: ship it or turn it off before review
- [ ] tvOS: keep the parked target or cut it

## Polish

- [ ] Smooth flag transition from the map banner to the full-screen flag
- [ ] iPad layouts beyond the readable-width column
- [ ] Map drawing on older devices with the detailed outlines

## Engineering

- [ ] `#Index` on `userID`, which needs a new schema version and a migration stage
- [ ] CI that runs the build, lint, and every package's tests
- [ ] Quiz Library opened at cold launch shows packs with no levels until the screen is rebuilt

# Geografy iOS — Launch Plan

What's still open before the first App Store submission. Phase 7 of the [2026-11-17 audit](audit/2026-11-17-app-audit.md) has the detail.

## Before submission

- [ ] Decide monetization, or ship free with nothing to buy
- [ ] Decide Mac Catalyst and tvOS, and turn off what won't ship
- [ ] Review the privacy manifest (`Geografy/PrivacyInfo.xcprivacy`) against what the app collects
- [ ] Privacy policy and terms pages live at the URLs Settings links to
- [ ] Release build passes the gate: zero warnings, zero SwiftLint violations, every package's tests

## App Store Connect

- [ ] App record, bundle ID, and app group for the widget
- [ ] Game Center leaderboards created under the IDs in `GameCenterService.LeaderboardID`
- [ ] Screenshots for iPhone, and for iPad if it ships
- [ ] Description, keywords, and support URL
- [ ] Review notes: guest mode needs no account; Sign in with Apple is optional

## TestFlight

- [ ] Fresh install, upgrade from an earlier build, and Delete Account
- [ ] Widgets show today's country and the user's streak
- [ ] Notifications ask for permission and open the right screen when tapped
- [ ] VoiceOver, Dynamic Type at accessibility sizes, Reduce Motion, and Increase Contrast on each tab

# Geografy-iOS

Project instructions have been moved to `.instructions/geografy-ios.md`.

## Constitution

Every screen obeys the shared [`../iOS-Constitution/CONSTITUTION.md`](../iOS-Constitution/CONSTITUTION.md), with this app's identity marks, own articles, and recorded exceptions in [`CONSTITUTION.md`](./CONSTITUTION.md). Read both before any UI change. A departure that is not recorded there is a bug. Conforms as of the latest 2026-11-24 entry of the shared changelog; what is still open is listed under "Not yet conforming".

The shared file is read by path, so `iOS-Constitution` must be cloned beside this repo. When a session learns a rule from a correction, it writes it down in the same turn: a rule for every app as an amendment to the shared constitution, a rule for Geografy alone in `CONSTITUTION.md`.

## Instructions

Check `.instructions/` for all project-specific guidelines:

- `geografy-ios.md` — Architecture, conventions, component catalog, folder structure
- `adaptivity.md` — Narrows the constitution's Part IV: how every screen adapts to Appearance, Liquid Glass, Color Filters, Text Size, Reduce Motion, Increase Contrast, Show Borders, Reduce Transparency, and VoiceOver, with a check for each
- `macos-guidelines.md` — macOS Catalyst development guidelines (parked)
- `tvos-guidelines.md` — tvOS development guidelines (parked)

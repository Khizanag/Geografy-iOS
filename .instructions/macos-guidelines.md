# macOS Development Guidelines — Geografy

## 1. Window Management
- [ ] Default window size: 1100x750
- [ ] Minimum window size: 800x550
- [ ] Support Settings scene (Command+Comma)
- [ ] Replace `.fullScreenCover` with `.sheet` on macOS
- [ ] Consider multi-window for country detail (openWindow)

## 2. Navigation: Sidebar Instead of Tabs
- [ ] Replace TabView with NavigationSplitView on macOS
- [ ] Sidebar sections: Learn, Play, Explore, Me
- [ ] `.listStyle(.sidebar)` for native translucent sidebar
- [ ] Persist sidebar selection with `@SceneStorage`
- [ ] No "More" tab — show all sections directly in sidebar
- [ ] Placeholder in detail column when nothing selected

## 3. Menu Bar
- [ ] CommandMenu for Quiz (Cmd+Shift+Q quick quiz, Cmd+D daily challenge)
- [ ] Command+1/2/3 to switch sidebar sections
- [ ] Command+F to focus search
- [ ] Remove default "New Window" if not needed
- [ ] Help menu integration

## 4. Toolbar
- [ ] Move bottom action buttons to toolbar on macOS
- [ ] Search in toolbar: `.searchable(placement: .toolbar)`
- [ ] `.windowToolbarStyle(.unified)` for modern look
- [ ] `.navigationSubtitle()` for contextual info
- [ ] Keep toolbars sparse (3-5 items max)

## 5. Typography & Spacing
- [ ] Use SwiftUI semantic fonts (.title, .headline, .body) — not hardcoded sizes
- [ ] Reduce padding on macOS (16pt page padding vs 20pt iOS)
- [ ] Smaller corner radius (8pt vs 12pt)
- [ ] Minimum click target 24pt (not 44pt like iOS)
- [ ] `.controlSize(.small)` for secondary controls

## 6. Pointer & Hover
- [ ] Hover effects on cards and interactive elements
- [ ] `.help()` tooltips on toolbar buttons
- [ ] No hover on non-interactive elements

## 7. macOS-Specific Views
- [ ] `Table` for country lists (sortable columns)
- [ ] `Settings` scene for preferences
- [ ] `.onExitCommand` for Escape in quizzes
- [ ] `.onDeleteCommand` for removing favorites
- [ ] Toggle renders as checkbox (correct — don't force switch style)

## 8. Settings / Preferences
- [ ] `Settings` scene in App body
- [ ] TabView inside Settings (General, Appearance, etc.)
- [ ] Remove Settings from sidebar — it's in menu bar
- [ ] Command+Comma wired automatically

## 9. Keyboard Shortcuts
- [ ] Command+F: focus search
- [ ] 1/2/3/4: quiz answer selection
- [ ] Escape: cancel quiz, dismiss sheet
- [ ] Arrow keys + Enter: quiz navigation
- [ ] Tab key cycles through controls
- [ ] Command+R: random country

## 10. Context Menus (Right-Click)
- [ ] Country rows: View Details, Add to Favorites, Compare, Copy Name
- [ ] Flag images: Copy Flag
- [ ] Travel items: Mark as Visited, Remove
- [ ] Keep concise (5-8 items max)

## 11. Dark / Light Mode
- [ ] Test all DesignSystem.Color tokens in both modes
- [ ] Sidebar uses system vibrancy — no opaque backgrounds
- [ ] `.glassEffect()` fallback: `.background(.thinMaterial)` on macOS
- [ ] Respect system accent color

## 12. What NOT to Do
- [x] No bottom tab bars — use sidebar
- [ ] No `.fullScreenCover` — use `.sheet`
- [ ] No large title navigation (`.large`)
- [ ] No pull-to-refresh — use toolbar refresh button
- [ ] No bottom action buttons — move to toolbar
- [ ] No oversized touch targets (44pt+) — use 24-28pt
- [ ] No haptics on macOS — guard with `#if os(iOS)`
- [ ] No "More" tab — all items in sidebar
- [ ] No `UIScreen`/`UIDevice` references

## 13. App Review
- [ ] Settings/Preferences window required
- [ ] Standard menus (Quit, About, Preferences) present
- [ ] Full keyboard navigability
- [ ] Not a "blown-up iPhone" — proper sidebar + detail
- [ ] Network entitlement for World Bank API
- [ ] Sandbox enabled
- [ ] Hardened Runtime enabled

## 14. Accessibility
- [ ] Tab key reaches all interactive elements
- [ ] VoiceOver works with macOS gestures
- [ ] Focus rings visible (don't suppress)
- [ ] Reduce Motion respected
- [ ] Increase Contrast supported

## Implementation Priority
1. NavigationSplitView sidebar (replace TabView)
2. Settings scene
3. Menu bar commands + keyboard shortcuts
4. Toolbar migration (bottom → top)
5. Table view for country lists
6. Context menus on all content
7. Hover effects on cards
8. Typography/spacing platform tokens
9. Window management
10. Accessibility audit

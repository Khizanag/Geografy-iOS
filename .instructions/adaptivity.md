# Adaptivity

Geografy adapts to every system display and accessibility setting a person can change. These rules are part of the project's constitution: a screen that breaks one of them isn't done, the same as a screen that doesn't build.

Check each rule on the simulator before calling UI work finished. The **Check** line says how.

## Appearance

Every screen works in Light and Dark, and with the in-app theme override.

- Colors come from `DesignSystem.Color` tokens backed by asset colors with light and dark variants. No raw `Color.white`, `.black`, `Color(hex:)`, or `Color.red` for chrome. Data palettes (flags, continents, brands) are the exception and live in one place.
- Never force a color scheme on a screen or bar. The map's ocean follows the appearance, so its bar must too.

**Check:** Settings › Appearance, or `xcrun simctl ui <device> appearance dark`.

## Liquid Glass

The system's Liquid Glass setting (Clear or Tinted) must reach every glass surface.

- Use system glass: `.glassEffect`, `.buttonStyle(.glass)`, toolbars, and tab bars. Don't imitate glass with hand-made blur, gradients, or white overlays.
- Put text on glass only through system components, so the system can raise its contrast when Tinted is on.

## Color Filters

Never carry meaning in color alone. People with color filters or color blindness must get the same information.

- Right and wrong, good and bad, and states such as visited or want-to-visit pair the color with a symbol, a shape, or text.
- When `accessibilityDifferentiateWithoutColor` is on, add the non-color cue wherever the default design leans on color.

**Check:** Settings › Accessibility › Display & Text Size › Color Filters, or turn on Differentiate Without Color.

## Text Size

All text scales with Dynamic Type, up to the largest accessibility size.

- Use `DesignSystem.Font` text-style tokens. Fixed sizes are only for decorative numbers and SF Symbol icons that sit beside scaling text, and those should scale too via `@ScaledMetric`.
- Layouts reflow rather than clip: no fixed heights around text, allow wrapping, and switch side-by-side layouts to stacked ones at accessibility sizes (`dynamicTypeSize.isAccessibilitySize`, `ViewThatFits`, `AnyLayout`).
- Tap targets stay at least 44 × 44 pt.

**Check:** `xcrun simctl ui <device> content_size accessibility-extra-extra-extra-large`.

## Reduce Motion

When `accessibilityReduceMotion` is on, nothing moves for decoration.

- Replace slides, scales, bounces, parallax, and looping animations with a cross-fade or no animation. Keep motion that carries meaning, such as a progress bar filling, but make it short.
- Shared components handle this themselves, so every screen gets it for free.

## Increase Contrast

When `colorSchemeContrast == .increased`, everything stays readable and every edge stays visible.

- Every color asset has high-contrast variants for light and dark. Secondary and tertiary text, dividers, and card edges darken or lighten enough to read.
- Never rely on a faint fill alone to separate a card from the background; add a visible border at increased contrast.

## Show Borders

When `accessibilityShowButtonShapes` is on, every tappable thing looks tappable.

- Text-only buttons gain an underline or an outline. Shared button styles do this themselves.
- Cards and rows that act as buttons keep a visible edge.

## Reduce Transparency

When `accessibilityReduceTransparency` is on, translucent surfaces become solid.

- System materials and glass adapt by themselves. Custom translucency, such as `.opacity` overlays used as backgrounds or blurred backdrops, switches to the solid token color.

## VoiceOver

Everything reads, in a sensible order, with nothing extra.

- Every interactive element has a label that says what it is, plus a hint when the result isn't obvious. Icon-only buttons always have a label.
- Decorative images and icons are `accessibilityHidden(true)`. Rows and cards combine their parts into one element with `.accessibilityElement(children: .combine)`.
- Headers carry `.isHeader`, selected items carry `.isSelected`, and live changes (scores, timers, results) post announcements.

**Check:** turn on VoiceOver, or use Xcode's Accessibility Inspector, and swipe through each screen.

## Where it lives

Adaptivity belongs in the design system first. A shared component that handles a setting fixes every screen that uses it, so fix the component, not each screen.

import SwiftUI

public extension View {
    /// Makes a sheet exactly as tall as its content, under a navigation bar or not. At accessibility text sizes
    /// it opens full height and scrolls.
    ///
    /// Leave the content without a background: below full height, iOS draws the sheet in Liquid Glass.
    /// The content runs to the sheet's bottom edge, so its own bottom padding sets the gap there: give it the same
    /// padding as its sides and buttons sit evenly inside the sheet.
    func fittedSheet() -> some View {
        modifier(FittedSheetModifier())
    }
}

// MARK: - Modifier
private struct FittedSheetModifier: ViewModifier {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // Only first guesses; the real values arrive once the sheet is laid out.
    @State private var contentHeight: CGFloat = 300
    @State private var insets = EdgeInsets()
    /// Bumped when the calibration changes, which it can't announce itself.
    @State private var calibrationRevision = 0
    @State private var settleCheck: Task<Void, Never>?

    func body(content: Content) -> some View {
        ScrollView {
            content
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.height
                } action: { height in
                    contentHeight = height.rounded()
                }
        }
        .scrollBounceBehavior(.basedOnSize)
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.containerSize.height - geometry.contentSize.height
        } action: { _, slack in
            checkFit(slack: slack)
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .onGeometryChange(for: EdgeInsets.self) { proxy in
            proxy.safeAreaInsets
        } action: { newInsets in
            insets.top = newInsets.top.rounded()
            // While the sheet settles, its bottom inset drops to zero and eases back; following it opened the
            // sheet that much too tall and then shrank it. The home indicator's inset never changes, so keep it.
            if newInsets.bottom > 0 {
                insets.bottom = newInsets.bottom.rounded()
            }
        }
        .presentationDetents(dynamicTypeSize.isAccessibilitySize ? [.large] : [.height(sheetHeight)])
    }

    /// The content plus the navigation bar above it, if any. A height detent leaves the bottom safe area below it,
    /// so that comes back out of the measured height.
    var sheetHeight: CGFloat {
        _ = calibrationRevision
        return contentHeight + insets.top - insets.bottom + FittedSheetCalibration.adjustment(hasBar: hasBar)
    }

    var hasBar: Bool {
        insets.top > 0
    }

    /// Once the sheet has settled, room left over in it, or content cut off, means the system lays sheets out
    /// differently here than the calibration says: correct it once, and every later sheet opens at its height.
    func checkFit(slack: CGFloat) {
        settleCheck?.cancel()
        guard !dynamicTypeSize.isAccessibilitySize else { return }
        settleCheck = Task {
            try? await Task.sleep(for: .milliseconds(400))
            // A sheet whose content outgrows the screen scrolls; that's no sign of a wrong calibration.
            guard !Task.isCancelled, abs(slack) >= 1, abs(slack) <= FittedSheetCalibration.maxCorrection else { return }
            FittedSheetCalibration.correct(by: slack.rounded(), hasBar: hasBar)
            calibrationRevision += 1
        }
    }
}

// MARK: - Calibration
/// How far a height detent must differ from the content height, plus the bar above it, less the home indicator's
/// inset, for the sheet to end where its content does. A partial-height sheet floats inside the screen, and one with
/// a bar draws it over part of its content's room, so the two kinds differ. Measured on an iPhone; the first sheet
/// of a kind that settles anywhere it differs corrects it, and the rest of that kind open at their height.
@MainActor
private enum FittedSheetCalibration {
    static let maxCorrection: CGFloat = 80

    private static var withBar: CGFloat = -52
    private static var withoutBar: CGFloat = 0

    static func adjustment(hasBar: Bool) -> CGFloat {
        hasBar ? withBar : withoutBar
    }

    static func correct(by slack: CGFloat, hasBar: Bool) {
        if hasBar {
            withBar -= slack
        } else {
            withoutBar -= slack
        }
    }
}

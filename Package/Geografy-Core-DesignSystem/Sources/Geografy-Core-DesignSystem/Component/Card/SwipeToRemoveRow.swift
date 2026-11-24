import SwiftUI

/// A row in a card that swipes left to show a red Remove, as a `List` row's trailing swipe does. The system's
/// swipe actions work only in a `List`, so cards in a scroll view use this instead (article 1): it opens and
/// closes like the system's, and offers the same Remove to VoiceOver as an action. The long press is the row's
/// `RowListMenu`.
struct SwipeToRemoveRow<Content: View>: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let onRemove: () -> Void
    @ViewBuilder let content: () -> Content

    @State private var offset: CGFloat = 0
    @State private var dragStartOffset: CGFloat = 0

    private let revealWidth: CGFloat = 88

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .trailing) {
            if offset < 0 {
                removeButton
                    .transition(.opacity)
            }
            content()
                .background(DesignSystem.Color.cardBackground)
                .overlay {
                    // While open, a tap on the row closes it instead of opening it; the overlay slides with the
                    // row, so the revealed button still takes its own tap.
                    if offset < 0 {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture { close() }
                    }
                }
                .offset(x: offset)
        }
        .clipped()
        #if os(iOS)
        .gesture(
            SidewaysPan(
                onChanged: { translation in offset = min(0, dragStartOffset + translation) },
                onEnded: settle
            )
        )
        #endif
        .accessibilityAction(named: Text("Remove", bundle: .module), onRemove)
    }
}

// MARK: - Subviews
private extension SwipeToRemoveRow {
    var removeButton: some View {
        Button(action: onRemove) {
            Label("Remove", systemImage: "trash")
                .labelStyle(.iconOnly)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .frame(width: max(revealWidth, -offset))
                .frame(maxHeight: .infinity)
                .background(DesignSystem.Color.destructive)
        }
        .buttonStyle(.plain)
        .accessibilityHidden(true)
    }
}

// MARK: - Gesture
private extension SwipeToRemoveRow {
    /// Opens past half the button's width, or on a quick flick, as a list row's swipe does.
    func settle(translation: CGFloat, velocity: CGFloat) {
        let projected = dragStartOffset + translation + velocity * 0.2
        if projected < -revealWidth / 2 {
            open()
        } else {
            close()
        }
    }

    func open() {
        withAnimation(reduceMotion ? nil : .snappy(duration: 0.25)) { offset = -revealWidth }
        dragStartOffset = -revealWidth
    }

    func close() {
        withAnimation(reduceMotion ? nil : .snappy(duration: 0.25)) { offset = 0 }
        dragStartOffset = 0
    }
}

#if os(iOS)
/// A pan that begins only when it moves sideways, so the scroll view around the card keeps vertical drags, and
/// that cancels the row's own tap once it begins, which a SwiftUI drag over a button can't.
private struct SidewaysPan: UIGestureRecognizerRepresentable {
    let onChanged: (CGFloat) -> Void
    let onEnded: (_ translation: CGFloat, _ velocity: CGFloat) -> Void

    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let recognizer = UIPanGestureRecognizer()
        recognizer.delegate = context.coordinator
        return recognizer
    }

    func handleUIGestureRecognizerAction(_ recognizer: UIPanGestureRecognizer, context: Context) {
        let translation = recognizer.translation(in: recognizer.view).x
        switch recognizer.state {
        case .changed:
            onChanged(translation)
        case .ended, .cancelled, .failed:
            onEnded(translation, recognizer.velocity(in: recognizer.view).x)
        default:
            break
        }
    }

    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return false }
            let velocity = pan.velocity(in: pan.view)
            return abs(velocity.x) > abs(velocity.y)
        }
    }
}
#endif

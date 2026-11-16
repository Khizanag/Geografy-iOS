#if !os(tvOS)
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// The session's current card with its swipe. The drag lives here, so a drag frame redraws this card
/// and not the whole session screen.
struct FlashcardSwipeCard: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let card: FlashcardItem
    let isFlipped: Bool
    /// Set by the session when the card should leave the screen.
    let exit: FlashcardCardExit?
    let onTap: () -> Void
    let onRate: (SwipeFeedback) -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var cardOpacity: Double = 1

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                FlashcardCardView(card: card, isFlipped: isFlipped, onTap: onTap)
                    .equatable()
                    .environment(\.flashcardSwipeTint, swipeTint)
                    .accessibilityAction(named: "I knew it") { onRate(isFlipped ? .correct : .knewIt) }
                    .accessibilityAction(named: "Review again") { onRate(.wrong) }
                    .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.8), value: isFlipped)
                    .opacity(cardOpacity)
                    .frame(
                        width: max(geometry.size.width - DesignSystem.Spacing.xl * 2, 0),
                        height: max(geometry.size.height * 0.85, 0)
                    )
                    .offset(dragOffset)
                    .rotationEffect(.degrees(reduceMotion ? 0 : dragRotation))
                    .gesture(swipeGesture)
                    .overlay(alignment: .bottomTrailing) { swipeHintRight }
                    .overlay(alignment: .bottomLeading) { swipeHintLeft }
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .center
            )
        }
        .onChange(of: card.id) { enter() }
        .onChange(of: exit) { _, exit in
            if let exit {
                leave(exit)
            }
        }
    }
}

// MARK: - Exit
/// Where and how fast the current card flies off.
struct FlashcardCardExit: Equatable {
    let offscreenX: CGFloat
    let duration: Double
}

// MARK: - Subviews
private extension FlashcardSwipeCard {
    @ViewBuilder
    var swipeHintRight: some View {
        if dragOffset.width > 30 {
            Label(
                isFlipped ? "Correct" : "Knew It",
                systemImage: isFlipped ? "checkmark.circle.fill" : "bolt.circle.fill"
            )
            .font(DesignSystem.Font.title2)
            .fontWeight(.black)
            .foregroundStyle(DesignSystem.Color.success)
            .padding(DesignSystem.Spacing.lg)
            .rotationEffect(.degrees(15))
            .opacity(min(Double(dragOffset.width) / 100.0, 1.0))
            .scaleEffect(min(Double(dragOffset.width) / 100.0, 1.0))
        }
    }

    @ViewBuilder
    var swipeHintLeft: some View {
        if isFlipped, dragOffset.width < -30 {
            Label("Wrong", systemImage: "xmark.circle.fill")
                .font(DesignSystem.Font.title2)
                .fontWeight(.black)
                .foregroundStyle(DesignSystem.Color.error)
                .padding(DesignSystem.Spacing.lg)
                .rotationEffect(.degrees(-15))
                .opacity(min(Double(-dragOffset.width) / 100.0, 1.0))
                .scaleEffect(min(Double(-dragOffset.width) / 100.0, 1.0))
        }
    }
}

// MARK: - Gesture
private extension FlashcardSwipeCard {
    var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if isFlipped || value.translation.width > 20 {
                    dragOffset = value.translation
                }
            }
            .onEnded { value in
                if let rating = rating(forSwipe: value.translation.width) {
                    onRate(rating)
                } else {
                    withAnimation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.7)) {
                        dragOffset = .zero
                    }
                }
            }
    }

    /// An unflipped card only rates "knew it" to the right; a flipped one rates either way.
    func rating(forSwipe width: CGFloat) -> SwipeFeedback? {
        let threshold: CGFloat = 100
        if isFlipped {
            if width > threshold { return .correct }
            if width < -threshold { return .wrong }
            return nil
        }
        return width > threshold ? .knewIt : nil
    }
}

// MARK: - Motion
private extension FlashcardSwipeCard {
    func leave(_ exit: FlashcardCardExit) {
        if reduceMotion {
            dragOffset = .zero
            withAnimation(.easeOut(duration: 0.15)) { cardOpacity = 0 }
        } else {
            withAnimation(.easeIn(duration: exit.duration)) {
                dragOffset = CGSize(width: exit.offscreenX, height: 0)
            }
        }
    }

    func enter() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            dragOffset = reduceMotion ? .zero : CGSize(width: 400, height: 0)
        }
        if reduceMotion {
            withAnimation(.easeIn(duration: 0.15)) { cardOpacity = 1 }
        } else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                dragOffset = .zero
            }
        }
    }
}

// MARK: - Helpers
private extension FlashcardSwipeCard {
    var dragRotation: Double {
        Double(dragOffset.width) / 20.0
    }

    var swipeTint: FlashcardSwipeTint {
        let offset = dragOffset.width
        let color = offset >= 0 ? DesignSystem.Color.success : DesignSystem.Color.error
        if offset > 0 {
            return FlashcardSwipeTint(color: color, opacity: min(offset / 150.0, 0.35))
        } else if isFlipped {
            return FlashcardSwipeTint(color: color, opacity: min(-offset / 150.0, 0.35))
        }
        return FlashcardSwipeTint(color: color, opacity: 0)
    }
}
#endif

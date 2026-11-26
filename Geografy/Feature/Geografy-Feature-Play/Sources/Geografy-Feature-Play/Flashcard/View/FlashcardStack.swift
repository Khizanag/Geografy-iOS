#if !os(tvOS)
import Geografy_Core_DesignSystem
import SwiftUI

/// The session's cards as a stack: the top one to study, the next ones waiting behind it. The top card follows the
/// finger, tilting from its bottom edge, and a throw sends it off with the speed it was let go at; the card behind
/// grows into its place as the top one leaves, so a new card is never slid in from off screen.
struct FlashcardStack: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// The cards left, top first.
    let cards: [FlashcardItem]
    let flippedCardID: String?
    /// Set to throw the top card without a swipe, such as from a rating button.
    @Binding var pendingThrow: FlashcardThrow?
    let onFlip: () -> Void
    /// The top card is on its way off in this direction: play the feedback now.
    let onRelease: (FlashcardThrow) -> Void
    /// The top card has left: take it off the stack.
    let onThrown: (FlashcardThrow) -> Void
    let onShowDetails: () -> Void

    @State private var drag: CGSize = .zero
    @State private var flyingCardID: String?
    @State private var flyingOffset: CGSize = .zero
    /// Carries the card behind forward while the top one flies off, from wherever the drag had brought it.
    @State private var throwProgress: CGFloat = 0

    // MARK: - Body
    var body: some View {
        ZStack {
            ForEach(Array(cards.prefix(Self.visibleDepth).enumerated()).reversed(), id: \.element.id) { depth, card in
                stackedCard(card, depth: depth)
            }
        }
        .onChange(of: pendingThrow) { _, request in
            guard let request else { return }
            pendingThrow = nil
            throwTopCard(request)
        }
    }
}

// MARK: - Throw
/// Which way a card leaves, and so how it's rated: right for known, left for wrong.
enum FlashcardThrow: Equatable {
    case right
    case left

    var sign: CGFloat { self == .right ? 1 : -1 }
}

// MARK: - Cards
private extension FlashcardStack {
    static let visibleDepth = 3
    static let throwThreshold: CGFloat = 110
    static let throwDistance: CGFloat = 700
    static let depthLift: CGFloat = 24

    @ViewBuilder
    func stackedCard(_ card: FlashcardItem, depth: Int) -> some View {
        let isTop = depth == 0
        FlashcardCardView(
            card: card,
            isFlipped: card.id == flippedCardID,
            contentOpacity: contentOpacity(depth: depth),
            onShowDetails: onShowDetails
        )
            .overlay { if isTop { swipeStamp } }
            .scaleEffect(scale(depth: depth))
            .offset(y: lift(depth: depth))
            .opacity(depth < Self.visibleDepth - 1 ? 1 : backOpacity)
            .offset(offset(for: card, isTop: isTop))
            .rotationEffect(.degrees(rotation(for: card, isTop: isTop)), anchor: .bottom)
            .allowsHitTesting(isTop && flyingCardID == nil)
            .contentShape(.rect(cornerRadius: FlashcardStyle.cornerRadius))
            .onTapGesture { if isTop { flip() } }
            .gesture(isTop ? swipe : nil)
            .transition(.asymmetric(insertion: .opacity, removal: .identity))
            .accessibilityElement(children: .contain)
            .accessibilityHidden(!isTop)
            .accessibilityAction(named: Text("Flip card", bundle: .module)) { flip() }
            .accessibilityAction(named: Text("Got it", bundle: .module)) { throwTopCard(.right) }
            .accessibilityAction(named: Text("Wrong", bundle: .module)) { throwTopCard(.left) }
    }

    /// Before the card is turned, a right swipe says it was known at once.
    var rightStamp: Text {
        cards.first?.id == flippedCardID ? Text("Got It", bundle: .module) : Text("Knew It", bundle: .module)
    }

    /// A word stamped on the top card as it's dragged, saying how letting go will rate it.
    var swipeStamp: some View {
        let progress = min(abs(drag.width) / Self.throwThreshold, 1)
        let isRight = drag.width >= 0
        let color = isRight ? DesignSystem.Color.success : DesignSystem.Color.error
        return ZStack(alignment: isRight ? .topLeading : .topTrailing) {
            RoundedRectangle(cornerRadius: FlashcardStyle.cornerRadius, style: .continuous)
                .fill(color.opacity(DesignSystem.Opacity.tint * progress))
            RoundedRectangle(cornerRadius: FlashcardStyle.cornerRadius, style: .continuous)
                .strokeBorder(color.opacity(progress), lineWidth: 3)
            Label {
                isRight ? rightStamp : Text("Wrong", bundle: .module)
            } icon: {
                Image(systemName: isRight ? "checkmark.circle.fill" : "arrow.counterclockwise.circle.fill")
            }
            .font(DesignSystem.Font.title2)
            .foregroundStyle(color)
            .padding(DesignSystem.Spacing.lg)
            .rotationEffect(.degrees(isRight ? -12 : 12))
            .opacity(progress)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Geometry
private extension FlashcardStack {
    /// How far the top card has gone toward a throw, which brings the card behind it forward to meet it.
    var dragProgress: CGFloat {
        max(min(abs(drag.width) / Self.throwThreshold, 1), throwProgress)
    }

    func scale(depth: Int) -> CGFloat {
        let resting = 1 - 0.05 * CGFloat(depth)
        guard depth > 0 else { return 1 }
        return resting + 0.05 * dragProgress
    }

    /// Each card behind sits a little lower, so its edge shows under the one in front.
    func lift(depth: Int) -> CGFloat {
        let resting = Self.depthLift * CGFloat(depth)
        guard depth > 0 else { return 0 }
        return resting - Self.depthLift * dragProgress
    }

    /// The next card's question fades in as it comes forward; until then it would show through a turning card.
    func contentOpacity(depth: Int) -> Double {
        switch depth {
        case 0: 1
        case 1: dragProgress
        default: 0
        }
    }

    var backOpacity: Double {
        0.5 + 0.5 * dragProgress
    }

    func offset(for card: FlashcardItem, isTop: Bool) -> CGSize {
        if card.id == flyingCardID { return flyingOffset }
        return isTop ? drag : .zero
    }

    func rotation(for card: FlashcardItem, isTop: Bool) -> Double {
        guard !reduceMotion else { return 0 }
        let width = card.id == flyingCardID ? flyingOffset.width : (isTop ? drag.width : 0)
        return Double(width / 22)
    }
}

// MARK: - Gestures
private extension FlashcardStack {
    var swipe: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                drag = value.translation
            }
            .onEnded { value in
                let flung = value.predictedEndTranslation.width
                if abs(value.translation.width) > Self.throwThreshold || abs(flung) > Self.throwThreshold * 2.5 {
                    throwTopCard(flung >= 0 ? .right : .left, from: value.translation)
                } else {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                        drag = .zero
                    }
                }
            }
    }

    func flip() {
        guard flyingCardID == nil else { return }
        onFlip()
    }

    /// Sends the top card off the side it's going, then takes it off the stack once it's gone.
    func throwTopCard(_ direction: FlashcardThrow, from start: CGSize? = nil) {
        guard let top = cards.first, flyingCardID == nil else { return }
        onRelease(direction)
        throwProgress = dragProgress
        flyingCardID = top.id
        flyingOffset = start ?? drag
        drag = .zero
        let target = CGSize(width: direction.sign * Self.throwDistance, height: flyingOffset.height + 60)
        // Out, not in: the card leaves at the speed the finger let it go, rather than pausing at the edge.
        let animation: Animation = reduceMotion ? .easeOut(duration: 0.2) : .easeOut(duration: 0.3)
        withAnimation(animation) {
            flyingOffset = target
            throwProgress = 1
        } completion: {
            onThrown(direction)
            flyingCardID = nil
            flyingOffset = .zero
            throwProgress = 0
        }
    }
}
#endif

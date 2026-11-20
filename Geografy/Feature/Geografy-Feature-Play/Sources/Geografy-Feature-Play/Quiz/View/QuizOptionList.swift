import Geografy_Core_DesignSystem
import SwiftUI

/// The answers to a multiple-choice question: glass buttons that slide in, then show which one was right.
/// Every game that asks one question with a few answers uses it, so answering looks and feels the same everywhere.
struct QuizOptionList: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let options: [QuizOption]
    var layout: Layout = .list
    let selectedOptionID: UUID?
    let correctOptionID: UUID
    let showFeedback: Bool
    let onSelect: (UUID) -> Void

    @State private var isVisible = false

    // MARK: - Body
    var body: some View {
        content
            .onAppear { triggerEntrance() }
            .onChange(of: options.map(\.id)) { triggerEntrance() }
    }
}

// MARK: - Layout
extension QuizOptionList {
    enum Layout {
        /// One answer per row, for names.
        case list
        /// Two columns, for flags.
        case flagGrid
    }
}

// MARK: - Subviews
private extension QuizOptionList {
    @ViewBuilder
    var content: some View {
        switch layout {
        case .list:
            VStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(Array(options.enumerated()), id: \.element.id) { index, option in
                    button(for: option, index: index)
                        .offset(y: isVisible || reduceMotion ? 0 : 18)
                        .animation(entrance(index: index), value: isVisible)
                }
            }
        case .flagGrid:
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                    GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                ],
                spacing: DesignSystem.Spacing.sm
            ) {
                ForEach(Array(options.enumerated()), id: \.element.id) { index, option in
                    button(for: option, index: index)
                        .scaleEffect(isVisible || reduceMotion ? 1 : 0.88)
                        .animation(entrance(index: index), value: isVisible)
                        .accessibilityLabel("Flag \(index + 1)")
                }
            }
        }
    }

    func button(for option: QuizOption, index: Int) -> some View {
        QuizOptionButton(
            text: layout == .flagGrid ? nil : option.text,
            flagCode: layout == .flagGrid ? option.flagCode : nil,
            state: state(for: option),
            index: index,
            action: { onSelect(option.id) }
        )
        .opacity(isVisible ? 1 : 0)
        .accessibilityValue(accessibilityValue(for: option))
    }
}

// MARK: - Helpers
private extension QuizOptionList {
    func triggerEntrance() {
        guard !reduceMotion else {
            isVisible = true
            return
        }
        isVisible = false
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85).delay(0.12)) {
            isVisible = true
        }
    }

    /// Each answer springs in a moment after the one before; flags settle with a little more bounce.
    func entrance(index: Int) -> Animation? {
        guard !reduceMotion else { return nil }
        let isGrid = layout == .flagGrid
        return .spring(response: 0.42, dampingFraction: isGrid ? 0.78 : 0.82)
            .delay((isGrid ? 0.07 : 0.06) * Double(index))
    }

    func state(for option: QuizOption) -> QuizOptionButton.OptionState {
        guard showFeedback else {
            return selectedOptionID == option.id ? .disabled : .default
        }
        if option.id == correctOptionID {
            return .correct
        }
        if option.id == selectedOptionID {
            return .incorrect
        }
        return .disabled
    }

    func accessibilityValue(for option: QuizOption) -> String {
        switch state(for: option) {
        case .correct: "Correct answer"
        case .incorrect: "Your answer, incorrect"
        case .default, .disabled: ""
        }
    }
}

import Geografy_Core_DesignSystem
import SwiftUI

struct AlphabetJumpIndex: View {
    let letters: [String]
    let onSelect: (String) -> Void

    @GestureState private var isDragging = false
    @State private var selectedLetter: String?
    @State private var totalHeight: CGFloat = 0

    var body: some View {
        extractedContent
            .frame(width: 44)
            .contentShape(Rectangle())
            .accessibilityLabel("Alphabet index")
            .accessibilityHint("Drag to jump to a letter")
    }
}

// MARK: - Subviews
private extension AlphabetJumpIndex {
    var extractedContent: some View {
        VStack(spacing: 1) {
            ForEach(letters, id: \.self) { letter in
                Text(letter)
                    .font(DesignSystem.Font.roundedPico)
                    .foregroundStyle(
                        selectedLetter == letter
                            ? DesignSystem.Color.textPrimary
                            : DesignSystem.Color.accent
                    )
                    .frame(width: 20, height: 14)
            }
        }
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(DesignSystem.Color.cardBackground.opacity(isDragging ? 0.9 : 0.0))
                .animation(.easeInOut(duration: 0.15), value: isDragging)
        )
        .contentShape(Rectangle())
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.height
        } action: { height in
            totalHeight = height
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .updating($isDragging) { _, state, _ in
                    state = true
                }
                .onChanged { value in
                    let letter = letterAt(y: value.location.y)
                    guard letter != selectedLetter else { return }
                    selectedLetter = letter
                    onSelect(letter)
                }
                .onEnded { _ in
                    selectedLetter = nil
                }
        )
    }
}

// MARK: - Helpers
private extension AlphabetJumpIndex {
    func letterAt(y: CGFloat) -> String {
        guard !letters.isEmpty, totalHeight > 0 else { return "" }
        let fraction = max(0, min(1, y / totalHeight))
        let index = Int(fraction * CGFloat(letters.count))
        let clamped = max(0, min(letters.count - 1, index))
        return letters[clamped]
    }
}

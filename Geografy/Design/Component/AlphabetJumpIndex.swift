import SwiftUI

struct AlphabetJumpIndex: View {
    let letters: [String]
    let onSelect: (String) -> Void

    @GestureState private var isDragging = false
    @State private var selectedLetter: String?

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ForEach(letters, id: \.self) { letter in
                    Text(letter)
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            selectedLetter == letter
                                ? DesignSystem.Color.textPrimary
                                : DesignSystem.Color.accent
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: letterHeight(in: geometry))
                }
            }
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(DesignSystem.Color.cardBackground.opacity(isDragging ? 0.9 : 0.0))
                    .animation(.easeInOut(duration: 0.15), value: isDragging)
            )
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .updating($isDragging) { _, state, _ in
                        state = true
                    }
                    .onChanged { value in
                        let letter = letterAt(y: value.location.y, height: geometry.size.height)
                        guard letter != selectedLetter else { return }
                        selectedLetter = letter
                        onSelect(letter)
                    }
                    .onEnded { _ in
                        selectedLetter = nil
                    }
            )
        }
        .frame(width: 16)
    }
}

// MARK: - Helpers

private extension AlphabetJumpIndex {
    func letterHeight(in geometry: GeometryProxy) -> CGFloat {
        guard !letters.isEmpty else { return 10 }
        let available = geometry.size.height - 4
        return max(available / CGFloat(letters.count), 8)
    }

    func letterAt(y: CGFloat, height: CGFloat) -> String {
        guard !letters.isEmpty, height > 0 else { return "" }
        let adjustedY = y - 2
        let fraction = max(0, min(1, adjustedY / (height - 4)))
        let index = Int(fraction * CGFloat(letters.count))
        let clamped = max(0, min(letters.count - 1, index))
        return letters[clamped]
    }
}

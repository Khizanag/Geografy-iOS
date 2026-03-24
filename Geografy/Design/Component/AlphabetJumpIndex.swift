import SwiftUI

struct AlphabetJumpIndex: View {
    let letters: [String]
    let onSelect: (String) -> Void

    @State private var isDragging = false

    var body: some View {
        GeometryReader { geometry in
            letterColumn(in: geometry)
        }
        .frame(width: 20)
    }
}

// MARK: - Subviews

private extension AlphabetJumpIndex {
    func letterColumn(in geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            ForEach(letters, id: \.self) { letter in
                Text(letter)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(DesignSystem.Color.accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: letterHeight(in: geometry))
            }
        }
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(DesignSystem.Color.cardBackground.opacity(isDragging ? 0.9 : 0.0))
        )
        .animation(.easeInOut(duration: 0.15), value: isDragging)
        .gesture(indexDragGesture(in: geometry))
        .simultaneousGesture(indexTapGesture(in: geometry))
    }

    func letterHeight(in geometry: GeometryProxy) -> CGFloat {
        guard !letters.isEmpty else { return 14 }
        let available = geometry.size.height - 8
        return max(available / CGFloat(letters.count), 14)
    }

    func indexDragGesture(in geometry: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 4, coordinateSpace: .local)
            .onChanged { value in
                isDragging = true
                let letter = letter(at: value.location.y, in: geometry)
                onSelect(letter)
            }
            .onEnded { _ in
                isDragging = false
            }
    }

    func indexTapGesture(in geometry: GeometryProxy) -> some Gesture {
        SpatialTapGesture(coordinateSpace: .local)
            .onEnded { value in
                let letter = letter(at: value.location.y, in: geometry)
                onSelect(letter)
            }
    }

    func letter(at yOffset: CGFloat, in geometry: GeometryProxy) -> String {
        guard !letters.isEmpty else { return "" }
        let height = geometry.size.height - 8
        let index = Int(max(0, yOffset - 4) / height * CGFloat(letters.count))
        let clamped = max(0, min(letters.count - 1, index))
        return letters[clamped]
    }
}

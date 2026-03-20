import SwiftUI

struct ZoomableFlagView: View {
    let countryCode: String
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        ZStack {
            backdrop
            flagContent
        }
        .transition(.opacity)
    }
}

// MARK: - Subviews

private extension ZoomableFlagView {
    var backdrop: some View {
        Color.black.opacity(0.7)
            .ignoresSafeArea()
            .onTapGesture { dismiss() }
    }

    var flagContent: some View {
        GeometryReader { geo in
            let flagWidth = geo.size.width * 0.85

            FlagView(countryCode: countryCode, height: flagWidth * 0.6)
                .scaleEffect(scale)
                .offset(offset)
                .gesture(magnifyGesture)
                .gesture(dragGesture)
                .onTapGesture(count: 2) { toggleZoom() }
                .onTapGesture(count: 1) { dismiss() }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .shadow(radius: DesignSystem.Spacing.lg)
        }
    }
}

// MARK: - Gestures

private extension ZoomableFlagView {
    var magnifyGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                scale = min(max(lastScale * value.magnification, 1.0), 5.0)
            }
            .onEnded { _ in
                lastScale = scale
                if scale <= 1.0 { resetPosition() }
            }
    }

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard scale > 1.0 else { return }
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }
}

// MARK: - Actions

private extension ZoomableFlagView {
    func toggleZoom() {
        withAnimation(.spring(response: 0.3)) {
            if scale > 1.0 {
                resetPosition()
            } else {
                scale = 3.0
                lastScale = 3.0
            }
        }
    }

    func resetPosition() {
        withAnimation(.spring(response: 0.3)) {
            scale = 1.0
            lastScale = 1.0
            offset = .zero
            lastOffset = .zero
        }
    }

    func dismiss() {
        guard scale <= 1.0 else {
            resetPosition()
            return
        }
        withAnimation(.easeOut(duration: 0.2)) {
            onDismiss()
        }
    }
}

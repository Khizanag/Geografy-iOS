import SwiftUI

struct ZoomableFlagView: View {
    let countryCode: String
    let namespace: Namespace.ID
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var isReady = false

    var body: some View {
        ZStack {
            backdrop
            flagContent
        }
        .onAppear {
            Task {
                try? await Task.sleep(for: .milliseconds(500))
                isReady = true
            }
        }
    }
}

// MARK: - Subviews

private extension ZoomableFlagView {
    var backdrop: some View {
        Color.black.opacity(0.75)
            .ignoresSafeArea()
            .onTapGesture { dismiss() }
            .transition(.opacity)
    }

    var flagContent: some View {
        GeometryReader { geometry in
            let aspectRatio = FlagAspectRatio.ratio(for: countryCode) ?? 1.5
            let maxWidth = geometry.size.width * 0.9
            let maxHeight = geometry.size.height * 0.65
            let heightFromWidth = maxWidth / aspectRatio
            let targetHeight = min(heightFromWidth, maxHeight)

            ZStack {
                FlagView(countryCode: countryCode, height: targetHeight)
                    .matchedGeometryEffect(id: countryCode, in: namespace, isSource: false)
                    .shadow(radius: DesignSystem.Spacing.lg)
                    .scaleEffect(scale)
                    .offset(offset)
                    .simultaneousGesture(magnifyGesture)
                    .simultaneousGesture(dragGesture)
                    .onTapGesture(count: 2) { if isReady { toggleZoom() } }
                    .onTapGesture(count: 1) { dismiss() }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

// MARK: - Gestures

private extension ZoomableFlagView {
    var magnifyGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                guard isReady else { return }
                scale = min(max(lastScale * value.magnification, 1.0), 5.0)
            }
            .onEnded { _ in
                guard isReady else { return }
                lastScale = scale
                if scale <= 1.0 { resetPosition() }
            }
    }

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard isReady, scale > 1.0 else { return }
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                guard isReady else { return }
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
        onDismiss()
    }
}

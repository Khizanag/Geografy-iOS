import SwiftUI
import GeografyDesign
import GeografyCore

struct ZoomableFlagView: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    let countryCode: String
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
            closeButton
        }
        .accessibilityElement(children: .contain)
        .onAppear {
            Task {
                try? await Task.sleep(for: .milliseconds(400))
                isReady = true
            }
        }
    }
}

// MARK: - Subviews
private extension ZoomableFlagView {
    var backdrop: some View {
        Rectangle()
            .fill(reduceTransparency ? AnyShapeStyle(DesignSystem.Color.background) : AnyShapeStyle(.ultraThinMaterial))
            .ignoresSafeArea()
            .onTapGesture { dismiss() }
            .accessibilityHidden(true)
    }

    var closeButton: some View {
        VStack {
            HStack {
                Spacer()
                Button { onDismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(DesignSystem.Font.title)
                        .foregroundStyle(.secondary)
                        .padding(DesignSystem.Spacing.md)
                }
                .accessibilityLabel("Close")
            }
            Spacer()
        }
    }

    var flagContent: some View {
        GeometryReader { geometry in
            let aspectRatio = FlagAspectRatio.ratio(for: countryCode) ?? 1.5
            let maxWidth = geometry.size.width - DesignSystem.Spacing.xl * 2
            let maxHeight = geometry.size.height * 0.5
            let heightFromWidth = maxWidth / aspectRatio
            let targetHeight = min(heightFromWidth, maxHeight)

            FlagView(countryCode: countryCode, height: targetHeight)
                .geoShadow(.elevated)
                .accessibilityLabel("Flag of \(countryCode.uppercased())")
                .accessibilityHint("Double tap to close, pinch to zoom")
                .scaleEffect(scale)
                .offset(offset)
                #if !os(tvOS)
                .simultaneousGesture(magnifyGesture)
                .simultaneousGesture(dragGesture)
                .onTapGesture(count: 2) { if isReady { toggleZoom() } }
                #endif
                .onTapGesture(count: 1) { dismiss() }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Gestures
#if !os(tvOS)
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
#endif

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

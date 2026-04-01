import GeografyCore
import GeografyDesign
import SwiftUI

struct ZoomableOrgLogoView: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    let url: URL
    let organization: Organization
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        ZStack {
            backdrop
            logoContent
            closeButton
        }
        .transition(.opacity)
    }
}

// MARK: - Subviews
private extension ZoomableOrgLogoView {
    var backdrop: some View {
        Rectangle()
            .fill(reduceTransparency ? AnyShapeStyle(DesignSystem.Color.background) : AnyShapeStyle(.ultraThinMaterial))
            .ignoresSafeArea()
            .onTapGesture { dismiss() }
            .accessibilityHidden(true)
    }

    var logoContent: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 280, maxHeight: 280)
                    .scaleEffect(scale)
                    .offset(offset)
                    #if !os(tvOS)
                    .simultaneousGesture(magnifyGesture)
                    .simultaneousGesture(dragGesture)
                    .onTapGesture(count: 2) { toggleZoom() }
                    #endif
                    .onTapGesture(count: 1) { dismiss() }
                    .shadow(radius: DesignSystem.Spacing.lg)
            default:
                ZStack {
                    Circle()
                        .fill(organization.highlightColor.opacity(0.15))
                        .frame(width: DesignSystem.Size.feature / 2, height: DesignSystem.Size.feature / 2)
                    Image(systemName: organization.icon)
                        .font(DesignSystem.IconSize.xxLarge)
                        .foregroundStyle(organization.highlightColor)
                }
                .onTapGesture { dismiss() }
            }
        }
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
}

// MARK: - Gestures
#if !os(tvOS)
private extension ZoomableOrgLogoView {
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
#endif

// MARK: - Actions
private extension ZoomableOrgLogoView {
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

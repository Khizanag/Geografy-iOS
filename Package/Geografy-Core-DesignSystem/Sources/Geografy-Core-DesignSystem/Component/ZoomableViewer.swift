import SwiftUI

public extension View {
    /// Shows `content` — a `ZoomableFlagView` or `ZoomableOrgLogoView` — full screen over a blur of this
    /// screen, under a bar of its own with the app's close button, the way every other cover closes.
    ///
    /// - Parameter title: Shown in the bar; nil when naming what's shown would give an answer away, as in a quiz.
    func zoomableViewer(
        isPresented: Binding<Bool>,
        title: String?,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        fullScreenCover(isPresented: isPresented) {
            ZoomableViewerContainer(title: title, content: content)
        }
    }
}

// MARK: - Container
private struct ZoomableViewerContainer<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    let title: String?
    @ViewBuilder let content: () -> Content

    var body: some View {
        NavigationStack {
            content()
                .navigationTitle(title ?? "")
                #if !os(tvOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        CircleCloseButton { dismiss() }
                    }
                }
        }
        .presentationBackground(backdrop)
    }

    var backdrop: AnyShapeStyle {
        reduceTransparency ? AnyShapeStyle(DesignSystem.Color.background) : AnyShapeStyle(.ultraThinMaterial)
    }
}

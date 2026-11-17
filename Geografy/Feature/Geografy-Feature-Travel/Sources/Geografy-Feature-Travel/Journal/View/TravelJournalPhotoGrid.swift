import Geografy_Core_DesignSystem
import SwiftUI

public struct TravelJournalPhotoGrid: View {
    // MARK: - Properties
    /// Previews scaled for the grid's cells.
    public let images: [UIImage]
    public var isReadOnly = false
    public var onDelete: ((Int) -> Void)?
    /// The photo at an index, scaled so its shorter side is at least the given pixels, for full screen.
    public var loadFullImage: (@MainActor (_ index: Int, _ minimumPixelSide: CGFloat) async -> UIImage?)?

    @State private var selectedPhotoIndex: SelectedIndex?

    /// The widest a cell gets: adaptive columns are at least 80pt, so they stay under twice that.
    static let cellPointSide: CGFloat = 160

    private let columns = [
        GridItem(
            .adaptive(minimum: 80),
            spacing: DesignSystem.Spacing.xs
        ),
    ]

    // MARK: - Body
    public var body: some View {
        LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.xs) {
            ForEach(images.indices, id: \.self) { index in
                photoCell(at: index)
            }
        }
        .zoomableViewer(isPresented: isViewingPhoto, title: viewerTitle) {
            if let selectedPhotoIndex {
                fullScreenPhoto(at: selectedPhotoIndex.value)
            }
        }
    }
}

// MARK: - SelectedIndex
private extension TravelJournalPhotoGrid {
    struct SelectedIndex: Identifiable {
        let value: Int
        var id: Int { value }
    }
}

// MARK: - Subviews
private extension TravelJournalPhotoGrid {
    func photoCell(at index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            Button {
                selectedPhotoIndex = SelectedIndex(value: index)
            } label: {
                Image(uiImage: images[index])
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 80, minHeight: 80)
                    .aspectRatio(1, contentMode: .fill)
                    .clipShape(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Photo \(index + 1) of \(images.count)")
            .accessibilityHint("Opens the photo full screen")

            if !isReadOnly {
                deleteOverlay(at: index)
            }
        }
    }

    func deleteOverlay(at index: Int) -> some View {
        Button {
            onDelete?(index)
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(DesignSystem.Font.iconSmall)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .background(
                    DesignSystem.Color.error,
                    in: Circle()
                )
        }
        .padding(DesignSystem.Spacing.xxs)
        .accessibilityLabel("Delete photo \(index + 1)")
    }

    func fullScreenPhoto(at index: Int) -> some View {
        FullScreenPhoto(
            preview: images[index],
            label: "Photo \(index + 1) of \(images.count)"
        ) { minimumPixelSide in
            await loadFullImage?(index, minimumPixelSide)
        }
    }
}

// MARK: - Helpers
private extension TravelJournalPhotoGrid {
    var isViewingPhoto: Binding<Bool> {
        Binding {
            selectedPhotoIndex != nil
        } set: { isPresented in
            if !isPresented { selectedPhotoIndex = nil }
        }
    }

    var viewerTitle: String? {
        selectedPhotoIndex.map { String(localized: "Photo \($0.value + 1) of \(images.count)") }
    }
}

// MARK: - FullScreenPhoto
/// Shows the grid's preview at once, then swaps in a copy sharp enough for the screen.
private struct FullScreenPhoto: View {
    // MARK: - Properties
    @Environment(\.displayScale) private var displayScale

    let preview: UIImage
    let label: LocalizedStringKey
    let load: @MainActor (_ minimumPixelSide: CGFloat) async -> UIImage?

    @State private var fullImage: UIImage?

    // MARK: - Body
    var body: some View {
        GeometryReader { geometryReader in
            Image(uiImage: fullImage ?? preview)
                .resizable()
                .scaledToFit()
                .frame(width: geometryReader.size.width, height: geometryReader.size.height)
                .accessibilityLabel(label)
                .task {
                    let side = min(geometryReader.size.width, geometryReader.size.height) * displayScale
                    fullImage = await load(side)
                }
        }
    }
}

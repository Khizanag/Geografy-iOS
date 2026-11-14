import Geografy_Core_DesignSystem
import SwiftUI

/// A stored journal photo filling a square, decoded off the main thread at the size it's drawn.
struct TravelJournalPhotoThumbnail: View {
    // MARK: - Properties
    @Environment(\.displayScale) private var displayScale

    let url: URL
    let side: CGFloat

    @State private var image: UIImage?

    // MARK: - Body
    var body: some View {
        content
            .task(id: url) {
                image = await TravelJournalPhotoCache.shared.image(at: url, minimumPixelSide: pixelSide)
            }
    }
}

// MARK: - Subviews
private extension TravelJournalPhotoThumbnail {
    @ViewBuilder
    var content: some View {
        if let image = image ?? TravelJournalPhotoCache.shared.cachedImage(at: url, minimumPixelSide: pixelSide) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            DesignSystem.Color.cardBackgroundHighlighted
        }
    }
}

// MARK: - Helpers
private extension TravelJournalPhotoThumbnail {
    var pixelSide: CGFloat { side * displayScale }
}

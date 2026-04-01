import Geografy_Core_DesignSystem
import SwiftUI

public struct TravelJournalPhotoGrid: View {
    public let images: [UIImage]
    public var isReadOnly = false
    public var onDelete: ((Int) -> Void)?

    @State private var selectedPhotoIndex: SelectedIndex?

    private let columns = [
        GridItem(
            .adaptive(minimum: 80),
            spacing: DesignSystem.Spacing.xs
        ),
    ]

    public var body: some View {
        LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.xs) {
            ForEach(images.indices, id: \.self) { index in
                photoCell(at: index)
            }
        }
        .fullScreenCover(item: $selectedPhotoIndex) { selected in
            fullScreenPhoto(at: selected.value)
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
        Button {
            selectedPhotoIndex = SelectedIndex(value: index)
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: images[index])
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 80, minHeight: 80)
                    .aspectRatio(1, contentMode: .fill)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: DesignSystem.CornerRadius.small
                        )
                    )

                if !isReadOnly {
                    deleteOverlay(at: index)
                }
            }
        }
        .buttonStyle(.plain)
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
    }

    func fullScreenPhoto(at index: Int) -> some View {
        ZStack {
            DesignSystem.Color.background
                .ignoresSafeArea()
            Image(uiImage: images[index])
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
        }
        .overlay(alignment: .topTrailing) {
            closeButton
        }
    }

    var closeButton: some View {
        Button {
            selectedPhotoIndex = nil
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(DesignSystem.Font.iconLarge)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .padding(DesignSystem.Spacing.md)
        }
    }
}

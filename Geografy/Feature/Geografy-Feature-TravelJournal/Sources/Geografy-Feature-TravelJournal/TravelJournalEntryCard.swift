import Geografy_Core_DesignSystem
import SwiftUI

public struct TravelJournalEntryCard: View {
    @Environment(TravelJournalService.self) private var journalService

    public let entry: TravelJournalEntry
    public let countryName: String
    public let onTap: () -> Void

    public var body: some View {
        Button(action: onTap) {
            cardContent
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Subviews
private extension TravelJournalEntryCard {
    var cardContent: some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                headerRow
                if !entry.notes.isEmpty {
                    notesPreview
                }
                if !entry.photoFileNames.isEmpty {
                    photoPreviewRow
                }
                footerRow
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    var headerRow: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            FlagView(countryCode: entry.countryCode, height: 28)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .frame(width: 42)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .lineLimit(1)
                Text(countryName)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Spacer(minLength: 0)
            ratingStars
        }
    }

    var ratingStars: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
                Image(
                    systemName: star <= entry.rating
                        ? "star.fill"
                        : "star"
                )
                .font(DesignSystem.Font.micro)
                .foregroundStyle(DesignSystem.Color.warning)
            }
        }
    }

    var notesPreview: some View {
        Text(entry.notes)
            .font(DesignSystem.Font.subheadline)
            .foregroundStyle(DesignSystem.Color.textSecondary)
            .lineLimit(2)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    var photoPreviewRow: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(
                entry.photoFileNames.prefix(4),
                id: \.self
            ) { fileName in
                photoThumbnail(fileName: fileName)
            }
            if entry.photoFileNames.count > 4 {
                morePhotosIndicator
            }
            Spacer(minLength: 0)
        }
    }

    func photoThumbnail(fileName: String) -> some View {
        Group {
            if let image = journalService.loadPhoto(named: fileName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                DesignSystem.Color.cardBackgroundHighlighted
            }
        }
        .frame(
            width: DesignSystem.Size.xxl,
            height: DesignSystem.Size.xxl
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: DesignSystem.CornerRadius.small
            )
        )
    }

    var morePhotosIndicator: some View {
        Text("+\(entry.photoFileNames.count - 4)")
            .font(DesignSystem.Font.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(DesignSystem.Color.textSecondary)
            .frame(
                width: DesignSystem.Size.xxl,
                height: DesignSystem.Size.xxl
            )
            .background(
                DesignSystem.Color.cardBackgroundHighlighted,
                in: RoundedRectangle(
                    cornerRadius: DesignSystem.CornerRadius.small
                )
            )
    }

    var footerRow: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "calendar")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
            Text(entry.formattedDateRange)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
            if !entry.photoFileNames.isEmpty {
                photoCountBadge
            }
            Spacer(minLength: 0)
            durationBadge
        }
    }

    var photoCountBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: "photo")
                .font(DesignSystem.Font.nano)
            Text("\(entry.photoFileNames.count)")
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
        }
        .foregroundStyle(DesignSystem.Color.accent)
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .padding(.vertical, 2)
        .background(
            DesignSystem.Color.accent.opacity(0.12),
            in: Capsule()
        )
    }

    var durationBadge: some View {
        Text(durationText)
            .font(DesignSystem.Font.caption2)
            .foregroundStyle(DesignSystem.Color.textTertiary)
    }
}

// MARK: - Helpers
private extension TravelJournalEntryCard {
    var durationText: String {
        let days = entry.durationDays
        return days == 1 ? "1 day" : "\(days) days"
    }
}

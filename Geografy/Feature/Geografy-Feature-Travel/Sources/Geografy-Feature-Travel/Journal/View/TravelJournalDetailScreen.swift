import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct TravelJournalDetailScreen: View {
    // MARK: - Properties
    @Environment(TravelJournalService.self) private var journalService
    @Environment(\.displayScale) private var displayScale

    public let entry: TravelJournalEntry
    @Binding var activeSheet: TravelJournalScreen.ActiveSheet?
    public let countryDataService: CountryDataService

    @State private var photos: [LoadedPhoto] = []
    @State private var showDeleteConfirmation = false

    // MARK: - Body
    public var body: some View {
        extractedContent
            .navigationTitle(entry.title)
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .closeButtonPlacementLeading()
            .toolbar { toolbarContent }
            .task(id: entry.photoFileNames) { await loadPhotos() }
            .confirmationDialog(
                "Delete Entry",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    journalService.deleteEntry(entry)
                    activeSheet = nil
                }
            } message: {
                Text(
                    "Are you sure you want to delete this "
                        + "journal entry? This cannot be undone."
                )
            }
    }
}

// MARK: - Toolbar
private extension TravelJournalDetailScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            editButton
        }
    }

    var editButton: some View {
        Button {
            activeSheet = .editEntry(entry)
        } label: {
            Image(systemName: "pencil")
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.iconPrimary)
        }
        .accessibilityLabel("Edit Entry")
    }
}

// MARK: - Subviews
private extension TravelJournalDetailScreen {
    var extractedContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                headerSection
                if !entry.photoFileNames.isEmpty {
                    photosSection
                }
                if !entry.notes.isEmpty {
                    notesSection
                }
                detailsSection
                deleteButton
            }
            .padding(DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
    }

    var headerSection: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.md) {
                countryRow
                ratingRow
                dateRow
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    var countryRow: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            FlagView(countryCode: entry.countryCode, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxxs) {
                Text(countryName)
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(entry.formattedDateRange)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }

    var ratingRow: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= entry.rating ? "star.fill" : "star")
                    .font(DesignSystem.Font.title3)
                    .foregroundStyle(DesignSystem.Color.warning)
                    .accessibilityHidden(true)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Rated \(entry.rating) of 5 stars")
            Spacer(minLength: 0)
            durationBadge
        }
    }

    var durationBadge: some View {
        InfoPill(durationText, systemImage: "clock")
    }

    var dateRow: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            dateDetail(label: "Start", icon: "airplane.departure", date: entry.startDate)
            dateDetail(label: "End", icon: "airplane.arrival", date: entry.endDate)
            Spacer(minLength: 0)
        }
    }

    func dateDetail(label: String, icon: String, date: Date) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                Text(formattedDate(date))
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Content Sections
private extension TravelJournalDetailScreen {
    var photosSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            SectionHeaderView(
                title: "Photos (\(entry.photoFileNames.count))",
                icon: "photo.fill"
            )
            TravelJournalPhotoGrid(
                images: photos.map(\.image),
                isReadOnly: true,
                loadFullImage: { index, minimumPixelSide in
                    guard photos.indices.contains(index) else { return nil }
                    return await TravelJournalPhotoCache.shared.image(
                        at: photos[index].url,
                        minimumPixelSide: minimumPixelSide
                    )
                }
            )
        }
    }

    var notesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            SectionHeaderView(title: "Notes", icon: "note.text")
            CardView {
                Text(entry.notes)
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(DesignSystem.Spacing.md)
            }
        }
    }

    var detailsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            SectionHeaderView(title: "Details", icon: "info.circle")
            CardView {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    detailRow(icon: "calendar", label: "Duration", value: durationText)
                    detailRow(icon: "photo", label: "Photos", value: "\(entry.photoFileNames.count)")
                    detailRow(icon: "star.fill", label: "Rating", value: "\(entry.rating)/5")
                    detailRow(icon: "clock", label: "Created", value: formattedDate(entry.createdAt))
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
    }

    func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.iconPrimary)
                .frame(width: 20)
                .accessibilityHidden(true)
            Text(label)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            Spacer(minLength: 0)
            Text(value)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
        .accessibilityElement(children: .combine)
    }

    var deleteButton: some View {
        Button {
            showDeleteConfirmation = true
        } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "trash")
                    .accessibilityHidden(true)
                Text("Delete Entry")
            }
            .font(DesignSystem.Font.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(DesignSystem.Color.error)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                DesignSystem.Color.error.opacity(DesignSystem.Opacity.faint),
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
            )
        }
        .buttonStyle(PressButtonStyle())
        .padding(.top, DesignSystem.Spacing.sm)
    }
}

// MARK: - Helpers
private extension TravelJournalDetailScreen {
    var countryName: String {
        countryDataService.country(for: entry.countryCode)?.name
            ?? entry.countryCode
    }

    var durationText: String {
        "\(entry.durationDays) days"
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Photos
private extension TravelJournalDetailScreen {
    struct LoadedPhoto {
        let url: URL
        let image: UIImage
    }

    func loadPhotos() async {
        let urls = entry.photoFileNames.map(journalService.photoURL(named:))
        let images = await TravelJournalPhotoCache.shared.images(
            at: urls,
            minimumPixelSide: TravelJournalPhotoGrid.cellPointSide * displayScale
        )
        photos = zip(urls, images).compactMap { url, image in
            image.map { LoadedPhoto(url: url, image: $0) }
        }
    }
}

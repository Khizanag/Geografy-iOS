import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

struct TravelJournalDetailScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(TravelJournalService.self) private var journalService

    let entry: TravelJournalEntry
    @Binding var activeSheet: TravelJournalScreen.ActiveSheet?
    let countryDataService: CountryDataService

    @State private var showDeleteConfirmation = false

    var body: some View {
        extractedContent
            .navigationTitle(entry.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
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
        ToolbarItem(placement: .cancellationAction) {
            CircleCloseButton()
        }
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
                .foregroundStyle(DesignSystem.Color.accent)
        }
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
        CardView(cornerRadius: DesignSystem.CornerRadius.extraLarge) {
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
                .clipShape(RoundedRectangle(cornerRadius: 6))
            VStack(alignment: .leading, spacing: 2) {
                Text(countryName)
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(entry.formattedDateRange)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Spacer(minLength: 0)
        }
    }

    var ratingRow: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= entry.rating ? "star.fill" : "star")
                    .font(DesignSystem.Font.title3)
                    .foregroundStyle(DesignSystem.Color.warning)
            }
            Spacer(minLength: 0)
            durationBadge
        }
    }

    var durationBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
                .font(DesignSystem.Font.caption2)
            Text(durationText)
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
        }
        .foregroundStyle(DesignSystem.Color.accent)
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(DesignSystem.Color.accent.opacity(0.12), in: Capsule())
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
                .foregroundStyle(DesignSystem.Color.textTertiary)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                Text(formattedDate(date))
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
            }
        }
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
            TravelJournalPhotoGrid(images: loadedPhotos, isReadOnly: true)
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
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(width: 20)
            Text(label)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            Spacer(minLength: 0)
            Text(value)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
    }

    var deleteButton: some View {
        Button {
            showDeleteConfirmation = true
        } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "trash")
                Text("Delete Entry")
            }
            .font(DesignSystem.Font.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(DesignSystem.Color.error)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                DesignSystem.Color.error.opacity(0.1),
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
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
        let days = entry.durationDays
        return days == 1 ? "1 day" : "\(days) days"
    }

    var loadedPhotos: [UIImage] {
        entry.photoFileNames.compactMap { fileName in
            journalService.loadPhoto(named: fileName)
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

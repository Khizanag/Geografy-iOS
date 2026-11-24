#if !os(tvOS)
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import PhotosUI
import SwiftUI

// MARK: - Form Sections
extension TravelJournalEditorSheet {
    var countrySection: some View {
        VStack(
            alignment: .leading,
            spacing: DesignSystem.Spacing.xs
        ) {
            SectionHeaderView(title: "Country", icon: "globe")
            countrySelector
        }
    }

    var countrySelector: some View {
        Button { showCountryPicker = true } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    countrySelectorContent
                    Spacer(minLength: 0)
                    RowChevron()
                }
                .padding(DesignSystem.Spacing.sm)
            }
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityHint("Choose the country for this entry")
    }

    @ViewBuilder
    var countrySelectorContent: some View {
        if !countryCode.isEmpty {
            FlagView(countryCode: countryCode, height: 28)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraSmall, style: .continuous))
                .accessibilityHidden(true)
            Text(selectedCountryName)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(
                    DesignSystem.Color.textPrimary
                )
        } else {
            Image(systemName: "globe")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(
                    DesignSystem.Color.textSecondary
                )
                .accessibilityHidden(true)
            Text("Select a country")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(
                    DesignSystem.Color.textSecondary
                )
        }
    }

    var titleSection: some View {
        VStack(
            alignment: .leading,
            spacing: DesignSystem.Spacing.xs
        ) {
            SectionHeaderView(title: "Title", icon: "pencil")
            FormField("Trip title", text: $title)
        }
    }

    var dateSection: some View {
        VStack(
            alignment: .leading,
            spacing: DesignSystem.Spacing.xs
        ) {
            SectionHeaderView(title: "Dates", icon: "calendar")
            let layout = dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(spacing: DesignSystem.Spacing.sm))
                : AnyLayout(HStackLayout(spacing: DesignSystem.Spacing.sm))
            layout {
                datePicker(label: "Start", date: $startDate)
                datePicker(label: "End", date: $endDate)
            }
        }
    }

    func datePicker(
        label: String,
        date: Binding<Date>
    ) -> some View {
        CardView {
            VStack(
                alignment: .leading,
                spacing: DesignSystem.Spacing.xxs
            ) {
                Text(label)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(
                        DesignSystem.Color.textSecondary
                    )
                    .accessibilityHidden(true)
                DatePicker(
                    label,
                    selection: date,
                    displayedComponents: .date
                )
                .labelsHidden()
                .tint(DesignSystem.Color.accent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DesignSystem.Spacing.sm)
        }
    }

    var ratingSection: some View {
        VStack(
            alignment: .leading,
            spacing: DesignSystem.Spacing.xs
        ) {
            SectionHeaderView(
                title: "Rating",
                icon: "star.fill"
            )
            ratingPicker
        }
    }

    var ratingPicker: some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        withAnimation(
                            reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.6)
                        ) {
                            rating = star
                        }
                    } label: {
                        Image(
                            systemName: star <= rating
                                ? "star.fill"
                                : "star"
                        )
                        .font(DesignSystem.Font.iconLarge)
                        .foregroundStyle(DesignSystem.Color.warning)
                        .scaleEffect(star <= rating ? 1.1 : 1.0)
                    }
                    .accessibilityLabel(star == 1 ? "1 star" : "\(star) stars")
                    .accessibilityAddTraits(star == rating ? .isSelected : [])
                }
                Spacer(minLength: 0)
            }
            .padding(DesignSystem.Spacing.sm)
        }
    }

    var notesSection: some View {
        VStack(
            alignment: .leading,
            spacing: DesignSystem.Spacing.xs
        ) {
            SectionHeaderView(
                title: "Notes",
                icon: "note.text"
            )
            notesEditor
        }
    }

    var notesEditor: some View {
        FormField("What happened on this trip?", text: $notes, lineLimit: 5...12)
    }

    var photosSection: some View {
        VStack(
            alignment: .leading,
            spacing: DesignSystem.Spacing.xs
        ) {
            SectionHeaderView(
                title: "Photos",
                icon: "photo.fill"
            )
            photosPicker
            if !loadedImages.isEmpty {
                photosGrid
            }
        }
    }

    var photosPicker: some View {
        nonisolated(unsafe) let label = photosPickerLabel
        return PhotosPicker(
            selection: $selectedPhotos,
            maxSelectionCount: 20,
            matching: .images
        ) {
            label
        }
        .buttonStyle(PressButtonStyle())
    }

    var photosPickerLabel: some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "photo.badge.plus.fill")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.iconPrimary)
                    .accessibilityHidden(true)
                Text("Add Photos")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Spacer(minLength: 0)
                Text(photosCountText)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .padding(DesignSystem.Spacing.sm)
        }
    }

    var photosGrid: some View {
        TravelJournalPhotoGrid(
            images: loadedImages.map(\.image),
            onDelete: { deleteIndex in
                withAnimation(reduceMotion ? nil : .default) {
                    _ = loadedImages.remove(at: deleteIndex)
                }
            },
            loadFullImage: { index, minimumPixelSide in
                await fullImage(at: index, minimumPixelSide: minimumPixelSide)
            }
        )
    }

    var countryPickerSheet: some View {
        CoordinatedNavigationStack(showCloseButton: true) {
            CountryPicker(
                "Select Country",
                countries: countryDataService.countries,
                selectedCode: countryCode.isEmpty ? nil : countryCode
            ) { country in
                countryCode = country.code
            }
        }
    }
}

// MARK: - Actions
extension TravelJournalEditorSheet {
    func saveEntry() {
        let photoFileNames = saveNewPhotos()

        if let existing = existingEntry {
            existing.title = title
            existing.notes = notes
            existing.rating = rating
            existing.startDate = startDate
            existing.endDate = endDate
            existing.countryCode = countryCode
            let removedPhotos = existing.photoFileNames
                .filter { !photoFileNames.contains($0) }
            journalService.deletePhotos(fileNames: removedPhotos)
            existing.photoFileNames = photoFileNames
            journalService.updateEntry(existing)
        } else {
            let entry = TravelJournalEntry(
                countryCode: countryCode,
                title: title,
                notes: notes,
                rating: rating,
                startDate: startDate,
                endDate: endDate,
                photoFileNames: photoFileNames
            )
            journalService.addEntry(entry)
        }
        activeSheet = nil
    }

    /// Until the stored photos have loaded they aren't in `loadedImages`, and must not count as removed.
    func saveNewPhotos() -> [String] {
        let fileNames = loadedImages.compactMap { loadedImage in
            if let existingName = loadedImage.fileName {
                return existingName
            }
            guard let data = loadedImage.data.flatMap(UIImage.init(data:))?
                .jpegData(compressionQuality: 0.8) else {
                return nil
            }
            return journalService.savePhoto(data)
        }
        guard !existingPhotosLoaded, let storedFileNames = existingEntry?.photoFileNames else {
            return fileNames
        }
        return storedFileNames + fileNames.filter { !storedFileNames.contains($0) }
    }

    func loadSelectedPhotos(
        _ items: [PhotosPickerItem]
    ) {
        Task {
            var picks: [LoadedImage] = []
            for item in items {
                if let data = try? await item
                    .loadTransferable(type: Data.self),
                    let preview = await TravelJournalPhotoCache.image(
                        from: data,
                        minimumPixelSide: previewPixelSide
                    ) {
                    picks.append(
                        LoadedImage(
                            image: preview,
                            fileName: nil,
                            data: data
                        )
                    )
                }
            }
            loadedImages = loadedImages.filter { $0.fileName != nil } + picks
        }
    }

    func loadExistingPhotos(_ fileNames: [String]) async {
        let images = await TravelJournalPhotoCache.shared.images(
            at: fileNames.map(journalService.photoURL(named:)),
            minimumPixelSide: previewPixelSide
        )
        let existing = zip(fileNames, images).compactMap { fileName, image in
            image.map { LoadedImage(image: $0, fileName: fileName) }
        }
        loadedImages = existing + loadedImages.filter { $0.fileName == nil }
        existingPhotosLoaded = true
    }

    func fullImage(at index: Int, minimumPixelSide: CGFloat) async -> UIImage? {
        guard loadedImages.indices.contains(index) else { return nil }
        let loadedImage = loadedImages[index]
        if let fileName = loadedImage.fileName {
            return await TravelJournalPhotoCache.shared.image(
                at: journalService.photoURL(named: fileName),
                minimumPixelSide: minimumPixelSide
            )
        }
        guard let data = loadedImage.data else { return nil }
        return await TravelJournalPhotoCache.image(from: data, minimumPixelSide: minimumPixelSide)
    }
}

// MARK: - Helpers
extension TravelJournalEditorSheet {
    var isEditing: Bool { existingEntry != nil }

    var canSave: Bool {
        let hasTitle = !title
            .trimmingCharacters(in: .whitespaces).isEmpty
        let hasCountry = !countryCode.isEmpty
        return hasTitle && hasCountry
    }

    var selectedCountryName: String {
        countryDataService.country(for: countryCode)?.name
            ?? countryCode
    }

    var previewPixelSide: CGFloat {
        TravelJournalPhotoGrid.cellPointSide * displayScale
    }

    var photosCountText: String {
        loadedImages.isEmpty
            ? "Up to 20"
            : "\(loadedImages.count) selected"
    }
}
#endif

#if !os(tvOS)
import Geografy_Core_Common
import Geografy_Core_DesignSystem
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
                    Image(systemName: "chevron.right")
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(
                            DesignSystem.Color.textTertiary
                        )
                }
                .padding(DesignSystem.Spacing.sm)
            }
        }
        .buttonStyle(PressButtonStyle())
    }

    @ViewBuilder
    var countrySelectorContent: some View {
        if !countryCode.isEmpty {
            FlagView(countryCode: countryCode, height: 28)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            Text(selectedCountryName)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(
                    DesignSystem.Color.textPrimary
                )
        } else {
            Image(systemName: "globe")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(
                    DesignSystem.Color.textTertiary
                )
            Text("Select a country")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(
                    DesignSystem.Color.textTertiary
                )
        }
    }

    var titleSection: some View {
        VStack(
            alignment: .leading,
            spacing: DesignSystem.Spacing.xs
        ) {
            SectionHeaderView(title: "Title", icon: "pencil")
            TextField("Trip title", text: $title)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .tint(DesignSystem.Color.accent)
                .padding(DesignSystem.Spacing.sm)
                .background(
                    DesignSystem.Color.cardBackground,
                    in: RoundedRectangle(
                        cornerRadius: DesignSystem.CornerRadius.medium
                    )
                )
        }
    }

    var dateSection: some View {
        VStack(
            alignment: .leading,
            spacing: DesignSystem.Spacing.xs
        ) {
            SectionHeaderView(title: "Dates", icon: "calendar")
            HStack(spacing: DesignSystem.Spacing.sm) {
                datePicker(label: "Start", date: $startDate)
                datePicker(label: "End", date: $endDate)
            }
        }
    }

    func datePicker(
        label: String,
        date: Binding<Date>
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: DesignSystem.Spacing.xxs
        ) {
            Text(label)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(
                    DesignSystem.Color.textSecondary
                )
            DatePicker(
                "",
                selection: date,
                displayedComponents: .date
            )
            .labelsHidden()
            .tint(DesignSystem.Color.accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignSystem.Spacing.sm)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(
                cornerRadius: DesignSystem.CornerRadius.medium
            )
        )
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
        HStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(1...5, id: \.self) { star in
                Button {
                    withAnimation(
                        .spring(response: 0.3, dampingFraction: 0.6)
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
            }
            Spacer(minLength: 0)
        }
        .padding(DesignSystem.Spacing.sm)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(
                cornerRadius: DesignSystem.CornerRadius.medium
            )
        )
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
        TextEditor(text: $notes)
            .font(DesignSystem.Font.body)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .tint(DesignSystem.Color.accent)
            .scrollContentBackground(.hidden)
            .frame(minHeight: 120)
            .padding(DesignSystem.Spacing.sm)
            .background(
                DesignSystem.Color.cardBackground,
                in: RoundedRectangle(
                    cornerRadius: DesignSystem.CornerRadius.medium
                )
            )
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
                    .foregroundStyle(DesignSystem.Color.accent)
                Text("Add Photos")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Spacer(minLength: 0)
                Text(photosCountText)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            .padding(DesignSystem.Spacing.sm)
        }
    }

    var photosGrid: some View {
        TravelJournalPhotoGrid(
            images: loadedImages.map(\.image),
            onDelete: { deleteIndex in
                withAnimation {
                    _ = loadedImages.remove(at: deleteIndex)
                }
            }
        )
    }

    var countryPickerSheet: some View {
        countryPickerContent
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.inline)
    }

    var countryPickerContent: some View {
        List(filteredCountries) { country in
            Button {
                countryCode = country.code
                showCountryPicker = false
            } label: {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    FlagView(
                        countryCode: country.code,
                        height: 24
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 3)
                    )
                    Text(country.name)
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(
                            DesignSystem.Color.textPrimary
                        )
                    Spacer(minLength: 0)
                    if country.code == countryCode {
                        Image(systemName: "checkmark")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(
                                DesignSystem.Color.accent
                            )
                    }
                }
            }
        }
        .searchable(
            text: $countrySearchText,
            prompt: "Search countries"
        )
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

    func saveNewPhotos() -> [String] {
        loadedImages.compactMap { loadedImage in
            if let existingName = loadedImage.fileName {
                return existingName
            }
            guard let data = loadedImage.image
                .jpegData(compressionQuality: 0.8) else {
                return nil
            }
            return journalService.savePhoto(data)
        }
    }

    func loadSelectedPhotos(
        _ items: [PhotosPickerItem]
    ) {
        Task {
            var newImages: [LoadedImage] = loadedImages
                .filter { $0.fileName != nil }
            for item in items {
                if let data = try? await item
                    .loadTransferable(type: Data.self),
                    let uiImage = UIImage(data: data) {
                    newImages.append(
                        LoadedImage(
                            image: uiImage,
                            fileName: nil
                        )
                    )
                }
            }
            loadedImages = newImages
        }
    }

    func loadExistingPhotos(_ fileNames: [String]) {
        loadedImages = fileNames.compactMap { fileName in
            guard let image = journalService
                .loadPhoto(named: fileName) else {
                return nil
            }
            return LoadedImage(
                image: image,
                fileName: fileName
            )
        }
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

    var photosCountText: String {
        loadedImages.isEmpty
            ? "Up to 20"
            : "\(loadedImages.count) selected"
    }

    var filteredCountries: [Country] {
        let countries = countryDataService.countries
        guard !countrySearchText.isEmpty else {
            return countries.sorted { $0.name < $1.name }
        }
        return countries
            .filter {
                $0.name.localizedCaseInsensitiveContains(
                    countrySearchText
                )
            }
            .sorted { $0.name < $1.name }
    }
}
#endif

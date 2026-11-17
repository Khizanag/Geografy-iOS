#if !os(tvOS)
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import PhotosUI
import SwiftUI

public struct TravelJournalEditorSheet: View {
    // MARK: - Properties
    @Environment(HapticsService.self) private var hapticsService
    @Environment(TravelJournalService.self) var journalService
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.displayScale) var displayScale
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    @Binding var activeSheet: TravelJournalScreen.ActiveSheet?
    public let countryDataService: CountryDataService

    @State var title = ""
    @State var notes = ""
    @State var rating = 3
    @State var startDate = Date.now
    @State var endDate = Date.now
    @State var countryCode = ""
    @State var selectedPhotos: [PhotosPickerItem] = []
    @State var loadedImages: [LoadedImage] = []
    @State var existingPhotosLoaded = false
    @State var showCountryPicker = false

    let existingEntry: TravelJournalEntry?

    // MARK: - Init
    public init(
        entry: TravelJournalEntry? = nil,
        activeSheet: Binding<TravelJournalScreen.ActiveSheet?>,
        countryDataService: CountryDataService
    ) {
        self.existingEntry = entry
        _activeSheet = activeSheet
        self.countryDataService = countryDataService
        if let entry {
            _title = State(wrappedValue: entry.title)
            _notes = State(wrappedValue: entry.notes)
            _rating = State(wrappedValue: entry.rating)
            _startDate = State(wrappedValue: entry.startDate)
            _endDate = State(wrappedValue: entry.endDate)
            _countryCode = State(wrappedValue: entry.countryCode)
        }
    }

    // MARK: - Body
    public var body: some View {
        extractedContent
            .navigationTitle(isEditing ? "Edit Entry" : "New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .task {
                if let entry = existingEntry {
                    await loadExistingPhotos(entry.photoFileNames)
                }
            }
            .onChange(of: selectedPhotos) { _, newItems in
                loadSelectedPhotos(newItems)
            }
            .sheet(isPresented: $showCountryPicker) {
                countryPickerSheet
            }
    }
}

// MARK: - LoadedImage
extension TravelJournalEditorSheet {
    struct LoadedImage: Identifiable {
        let id = UUID()
        /// Scaled for the grid; the stored file, or `data` for a new pick, holds the full photo.
        let image: UIImage
        let fileName: String?
        var data: Data?
    }
}

// MARK: - Toolbar
private extension TravelJournalEditorSheet {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            saveButton
        }
    }

    var saveButton: some View {
        Button("Save", systemImage: "checkmark", role: .confirm) {
            hapticsService.notification(.success)
            saveEntry()
        }
        .disabled(!canSave)
    }
}

// MARK: - Subviews
private extension TravelJournalEditorSheet {
    var extractedContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                countrySection
                titleSection
                dateSection
                ratingSection
                notesSection
                photosSection
            }
            .padding(DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
        }
    }
}
#endif

#if !os(tvOS)
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import PhotosUI
import SwiftUI

public struct TravelJournalEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HapticsService.self) private var hapticsService
    @Environment(TravelJournalService.self) var journalService

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
    @State var showCountryPicker = false
    @State var countrySearchText = ""

    let existingEntry: TravelJournalEntry?

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

    public var body: some View {
        extractedContent
            .navigationTitle(isEditing ? "Edit Entry" : "New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .task {
                if let entry = existingEntry {
                    loadExistingPhotos(entry.photoFileNames)
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
        let image: UIImage
        let fileName: String?
    }
}

// MARK: - Toolbar
private extension TravelJournalEditorSheet {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            CircleCloseButton()
        }
        ToolbarItem(placement: .confirmationAction) {
            saveButton
        }
    }

    var saveButton: some View {
        Button {
            hapticsService.impact(.medium)
            saveEntry()
        } label: {
            Text("Save")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(
                    canSave
                        ? DesignSystem.Color.accent
                        : DesignSystem.Color.textTertiary
                )
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

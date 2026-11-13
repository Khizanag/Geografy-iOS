import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct CountrySaveToCollectionSheet: View {
    // MARK: - Properties
    @Environment(CollectionService.self) private var collectionService
    @Environment(HapticsService.self) private var hapticsService
    public let countryCode: String
    public let countryName: String

    public init(countryCode: String, countryName: String) {
        self.countryCode = countryCode
        self.countryName = countryName
    }

    @State private var showNewCollection = false

    // MARK: - Body
    public var body: some View {
        content
            .screenBackground()
            .navigationTitle("Save to Collection")
            .navigationBarTitleDisplayMode(.inline)
            .nameEntryAlert(
                "New Collection",
                isPresented: $showNewCollection,
                placeholder: "Collection name",
                confirmTitle: "Create & Save",
                isValid: collectionService.isAvailableName
            ) { name in
                collectionService.add(itemID: countryCode, type: .country, to: name)
                hapticsService.notification(.success)
            }
    }
}

// MARK: - Content
private extension CountrySaveToCollectionSheet {
    var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                itemHeader

                if !collectionService.collectionNames.isEmpty {
                    existingCollections
                }

                newCollectionButton
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
        }
    }

    var itemHeader: some View {
        CardView(cornerRadius: DesignSystem.CornerRadius.medium) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                FlagView(countryCode: countryCode, height: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(countryName)
                        .font(DesignSystem.Font.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)

                    Text("Country")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }

                Spacer()
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    var existingCollections: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text("Collections")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            ForEach(collectionService.collectionNames, id: \.self) { name in
                collectionToggleRow(name)
            }
        }
    }

    func collectionToggleRow(_ name: String) -> some View {
        let isSaved = collectionService.collections(
            containing: countryCode,
            type: .country
        )
        .contains(name)

        return Button {
            hapticsService.impact(.light)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                collectionService.toggle(
                    itemID: countryCode,
                    type: .country,
                    in: name
                )
            }
        } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "folder.fill")
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.accent)

                    Text(name)
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)

                    Spacer()

                    Image(
                        systemName: isSaved
                            ? "checkmark.circle.fill"
                            : "circle"
                    )
                    .font(DesignSystem.Font.title3)
                    .foregroundStyle(
                        isSaved
                            ? DesignSystem.Color.accent
                            : DesignSystem.Color.textTertiary
                    )
                }
                .padding(DesignSystem.Spacing.sm)
            }
        }
        .buttonStyle(PressButtonStyle())
    }

    var newCollectionButton: some View {
        GlassButton(
            "New Collection",
            systemImage: "plus.circle",
            fullWidth: true
        ) {
            showNewCollection = true
        }
    }
}

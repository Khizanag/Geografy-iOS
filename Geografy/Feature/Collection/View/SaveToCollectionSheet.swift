import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

struct SaveToCollectionSheet: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(CollectionService.self) private var collectionService
    @Environment(HapticsService.self) private var hapticsService

    let itemID: String
    let itemType: CollectionItem.ItemType
    let itemName: String

    @State private var showNewCollection = false
    @State private var newCollectionName = ""

    // MARK: - Body
    var body: some View {
        NavigationStack {
            content
                .background(DesignSystem.Color.background.ignoresSafeArea())
                .navigationTitle("Save to Collection")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { dismiss() }
                    }
                }
                .alert("New Collection", isPresented: $showNewCollection) {
                    newCollectionAlert
                }
        }
    }
}

// MARK: - Content
private extension SaveToCollectionSheet {
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
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: itemType.icon)
                .font(DesignSystem.Font.title3)
                .foregroundStyle(DesignSystem.Color.accent)
            VStack(alignment: .leading, spacing: 2) {
                Text(itemName)
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(itemType.displayName)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Spacer()
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
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
            containing: itemID,
            type: itemType
        )
        .contains(name)

        return Button {
            hapticsService.impact(.light)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                collectionService.toggle(
                    itemID: itemID,
                    type: itemType,
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

// MARK: - New Collection Alert
private extension SaveToCollectionSheet {
    @ViewBuilder
    var newCollectionAlert: some View {
        TextField("Collection name", text: $newCollectionName)
        Button("Cancel", role: .cancel) { newCollectionName = "" }
        Button("Create & Save") {
            let name = newCollectionName.trimmingCharacters(in: .whitespaces)
            guard !name.isEmpty else { return }
            collectionService.add(itemID: itemID, type: itemType, to: name)
            hapticsService.notification(.success)
            newCollectionName = ""
        }
    }
}

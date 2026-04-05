import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

struct CollectionsScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(CollectionService.self) private var collectionService
    @Environment(HapticsService.self) private var hapticsService

    @State private var showNewCollection = false
    @State private var newCollectionName = ""
    @State private var collectionToDelete: String?

    // MARK: - Body
    var body: some View {
        content
            .background { AmbientBlobsView(.standard) }
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle("My Collections")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .alert("New Collection", isPresented: $showNewCollection) {
                newCollectionAlert
            }
            .confirmationDialog(
                "Delete Collection",
                isPresented: deleteDialogBinding,
                titleVisibility: .visible
            ) {
                deleteDialogActions
            } message: {
                Text("All items in this collection will be removed.")
            }
    }
}

// MARK: - Content
private extension CollectionsScreen {
    @ViewBuilder
    var content: some View {
        if collectionService.collectionNames.isEmpty {
            emptyState
        } else {
            collectionList
        }
    }

    var emptyState: some View {
        ContentUnavailableView {
            Label("No Collections", systemImage: "folder")
        } description: {
            Text("Save countries, oceans, languages and more into collections.")
        } actions: {
            GlassButton("Create Collection", systemImage: "plus") {
                showNewCollection = true
            }
        }
    }

    var collectionList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(collectionService.collectionNames, id: \.self) { name in
                    collectionRow(name)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
    }

    func collectionRow(_ name: String) -> some View {
        let itemCount = collectionService.itemCount(in: name)
        let typeCounts = collectionService.typeCounts(in: name)

        return Button {
            hapticsService.impact(.light)
            coordinator.push(.collectionDetail(name))
        } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.md) {
                    collectionIcon(typeCounts: typeCounts)

                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                        Text(name)
                            .font(DesignSystem.Font.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(DesignSystem.Color.textPrimary)

                        Text("\(itemCount) item\(itemCount == 1 ? "" : "s")")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }

                    Spacer()

                    typeIcons(typeCounts: typeCounts)

                    Image(systemName: "chevron.right")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
        .buttonStyle(PressButtonStyle())
        .contextMenu {
            Button(role: .destructive) {
                collectionToDelete = name
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    func collectionIcon(
        typeCounts: [CollectionItem.ItemType: Int]
    ) -> some View {
        let primaryType = typeCounts
            .max(by: { $0.value < $1.value })?.key ?? .country

        return ZStack {
            Circle()
                .fill(DesignSystem.Color.accent.opacity(0.15))
                .frame(width: 44, height: 44)
            Image(systemName: "folder.fill")
                .font(DesignSystem.Font.title3)
                .foregroundStyle(DesignSystem.Color.accent)
        }
        .accessibilityLabel(primaryType.displayName)
    }

    func typeIcons(
        typeCounts: [CollectionItem.ItemType: Int]
    ) -> some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            ForEach(
                typeCounts.keys.sorted(by: { $0.rawValue < $1.rawValue }),
                id: \.self
            ) { type in
                Image(systemName: type.icon)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
        }
    }
}

// MARK: - Toolbar
private extension CollectionsScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                showNewCollection = true
            } label: {
                Label("Add", systemImage: "plus")
                    .foregroundStyle(DesignSystem.Color.iconPrimary)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Alerts
private extension CollectionsScreen {
    @ViewBuilder
    var newCollectionAlert: some View {
        TextField("Collection name", text: $newCollectionName)
        Button("Cancel", role: .cancel) { newCollectionName = "" }
        Button("Create") {
            let name = newCollectionName.trimmingCharacters(in: .whitespaces)
            guard !name.isEmpty else { return }
            hapticsService.impact(.medium)
            newCollectionName = ""
        }
    }

    var deleteDialogBinding: Binding<Bool> {
        Binding(
            get: { collectionToDelete != nil },
            set: { if !$0 { collectionToDelete = nil } }
        )
    }

    @ViewBuilder
    var deleteDialogActions: some View {
        Button("Cancel", role: .cancel) { collectionToDelete = nil }
        Button("Delete", role: .destructive) {
            if let name = collectionToDelete {
                collectionService.deleteCollection(name)
            }
            collectionToDelete = nil
        }
    }
}

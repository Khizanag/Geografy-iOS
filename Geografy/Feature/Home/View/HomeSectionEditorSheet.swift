import GeografyDesign
import SwiftUI

struct HomeSectionEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HomeSectionOrderService.self) private var orderService

    @State private var sections: [HomeSection]
    @State private var showResetConfirmation = false

    init(sections: [HomeSection]) {
        _sections = State(wrappedValue: sections)
    }

    var body: some View {
        sectionList
            .environment(\.editMode, .constant(.active))
            .navigationTitle("Edit Sections")
            .navigationBarTitleDisplayMode(.inline)
            .closeButtonPlacementLeading()
            .toolbar { toolbarContent }
            .confirmationDialog(
                "Reset Section Order",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible,
                actions: { resetDialogActions },
                message: { Text("This will restore the default section order.") }
            )
    }
}

// MARK: - Subviews
private extension HomeSectionEditorSheet {
    var sectionList: some View {
        List {
            ForEach(sections) { section in
                sectionRow(section)
            }
            .onMove { source, destination in
                sections.move(fromOffsets: source, toOffset: destination)
            }

            Section {
                resetButton
            }
        }
    }

    func sectionRow(_ section: HomeSection) -> some View {
        Label(section.displayName, systemImage: section.icon)
            .font(DesignSystem.Font.subheadline)
            .foregroundStyle(DesignSystem.Color.textPrimary)
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            doneButton
        }
    }

    var doneButton: some View {
        Button {
            orderService.reorder(to: sections)
            dismiss()
        } label: {
            Text("Done")
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
        .buttonStyle(.plain)
    }

    var resetButton: some View {
        Button(role: .destructive) {
            showResetConfirmation = true
        } label: {
            Label("Reset to Default", systemImage: "arrow.counterclockwise")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.error)
        }
    }

    @ViewBuilder
    var resetDialogActions: some View {
        Button("Reset to Default", role: .destructive) {
            withAnimation {
                sections = HomeSection.allCases.map { $0 }
            }
        }
        Button("Cancel", role: .cancel) {}
    }
}

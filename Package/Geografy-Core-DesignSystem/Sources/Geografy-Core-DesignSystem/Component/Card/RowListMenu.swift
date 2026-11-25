import SwiftUI

/// What a long press on a row in a `RowListCard` offers, as article 12 asks: a preview of the item first, then
/// Open, Copy, and Share, and Remove last when the row can be removed. Each kind of item defines this once.
public struct RowListMenu<Item> {
    // MARK: - Properties
    /// Nil for an item that has no page of its own to open.
    let open: ((Item) -> Void)?
    /// What Copy puts on the pasteboard and Share sends.
    let text: (Item) -> String
    let remove: ((Item) -> Void)?
    let preview: (Item) -> AnyView

    // MARK: - Init
    /// - Parameter preview: The item as its own screen opens. It's drawn outside the screen's environment, so it
    ///   takes values, never services.
    public init<Preview: View>(
        open: ((Item) -> Void)?,
        text: @escaping (Item) -> String,
        remove: ((Item) -> Void)? = nil,
        @ViewBuilder preview: @escaping (Item) -> Preview
    ) {
        self.open = open
        self.text = text
        self.remove = remove
        self.preview = { AnyView(preview($0)) }
    }
}

// MARK: - Modifier
extension View {
    /// The long-press preview and menu of `item`, with the swipe that removes it when the menu can.
    @ViewBuilder
    func rowListMenu<Item>(_ menu: RowListMenu<Item>, for item: Item) -> some View {
        // Opaque and rounded, so what the long press lifts is never an empty hole on the way in or out.
        let pressable = background(DesignSystem.Color.cardBackground)
            .contentShape(
                .contextMenuPreview,
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
            )
            .contextMenu {
                RowListMenuItems(menu: menu, item: item)
            } preview: {
                menu.preview(item)
                    .frame(width: RowListMenuLayout.previewWidth)
                    .background(DesignSystem.Color.cardBackground)
            }
        if let remove = menu.remove {
            SwipeToRemoveRow(onRemove: { remove(item) }, content: { pressable })
        } else {
            pressable
        }
    }
}

private enum RowListMenuLayout {
    /// One width, so the system's platter never shows a band around a preview it measured at another.
    static let previewWidth: CGFloat = 320
}

// MARK: - Menu Items
private struct RowListMenuItems<Item>: View {
    let menu: RowListMenu<Item>
    let item: Item

    var body: some View {
        Section {
            if let open = menu.open {
                Button {
                    open(item)
                } label: {
                    Label { Text("Open", bundle: .module) } icon: { Image(systemName: "arrow.up.forward.app") }
                }
            }
            #if os(iOS)
            Button {
                UIPasteboard.general.string = menu.text(item)
            } label: {
                Label { Text("Copy", bundle: .module) } icon: { Image(systemName: "doc.on.doc") }
            }
            #endif
            ShareLink(item: menu.text(item)) {
                Label { Text("Share", bundle: .module) } icon: { Image(systemName: "square.and.arrow.up") }
            }
        }
        if let remove = menu.remove {
            Section {
                Button(role: .destructive) {
                    remove(item)
                } label: {
                    Label { Text("Remove", bundle: .module) } icon: { Image(systemName: "trash") }
                }
            }
        }
    }
}

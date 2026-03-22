import SwiftUI

struct ThemesScreen: View {
    var body: some View {
        ComingSoonView(icon: "paintbrush.fill", title: "Themes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CircleCloseButton()
                }
            }
    }
}

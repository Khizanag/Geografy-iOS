import SwiftUI

struct ComingSoonSheet: View {
    let title: String
    let icon: String

    var body: some View {
        NavigationStack {
            ComingSoonView(icon: icon)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        GeoCloseButton()
                    }
                }
        }
    }
}

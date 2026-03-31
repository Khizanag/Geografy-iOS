import SwiftUI

struct ComingSoonSheet: View {
    let title: String
    let icon: String

    var body: some View {
        ComingSoonView(icon: icon, title: title, isDismissible: true)
    }
}

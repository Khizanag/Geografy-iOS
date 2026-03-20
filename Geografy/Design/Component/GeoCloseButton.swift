import SwiftUI

struct GeoCloseButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button { dismiss() } label: {
            Image(systemName: "xmark")
                .font(GeoIconSize.small)
                .foregroundStyle(GeoColors.textSecondary)
        }
        .buttonStyle(.borderless)
        .glassEffect(.regular.interactive(), in: .circle)
    }
}

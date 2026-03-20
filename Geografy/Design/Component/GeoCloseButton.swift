import SwiftUI

struct GeoCloseButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button { dismiss() } label: {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(GeoColors.textSecondary)
                .frame(width: 30, height: 30)
                .contentShape(Circle())
        }
        .glassEffect(.regular.interactive(), in: .circle)
    }
}

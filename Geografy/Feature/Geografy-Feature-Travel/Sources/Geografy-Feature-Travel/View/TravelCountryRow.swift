import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct TravelCountryRow: View {
    // MARK: - Properties
    @Environment(TravelService.self) private var travelService

    public let country: Country
    public let status: TravelStatus

    @State private var showPicker = false

    // MARK: - Body
    public var body: some View {
        Button { showPicker = true } label: {
            rowContent
        }
        .buttonStyle(PressButtonStyle())
        .sheet(isPresented: $showPicker) {
            TravelStatusPickerSheet(country: country)
        }
    }
}

// MARK: - Subviews
private extension TravelCountryRow {
    var rowContent: some View {
        CardView {
            CountryListRow(country: country, subtitle: country.continent.displayName) {
                statusBadge
                RowChevron()
            }
            .padding(DesignSystem.Spacing.sm)
        }
    }

    var statusBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: status.icon)
                .font(DesignSystem.Font.nano)
            Text(status.shortLabel)
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
        }
        .foregroundStyle(status.color)
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(status.color.opacity(0.15), in: Capsule())
    }
}

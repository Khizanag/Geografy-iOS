import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct TravelCountryRow: View {
    @Environment(TravelService.self) private var travelService

    public let country: Country
    public let status: TravelStatus

    @State private var showPicker = false

    public var body: some View {
        Button { showPicker = true } label: {
            rowContent
        }
        .buttonStyle(PressButtonStyle())
        .sheet(isPresented: $showPicker) {
            TravelStatusPickerSheet(country: country, isPresented: $showPicker)
        }
    }
}

// MARK: - Subviews
private extension TravelCountryRow {
    var rowContent: some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.sm) {
                FlagView(countryCode: country.code, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .frame(width: 54)
                countryInfo
                Spacer(minLength: 0)
                statusBadge
                Image(systemName: "chevron.right")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            .padding(DesignSystem.Spacing.sm)
        }
    }

    var countryInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(country.name)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(country.continent.displayName)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    var statusBadge: some View {
        HStack(spacing: 4) {
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

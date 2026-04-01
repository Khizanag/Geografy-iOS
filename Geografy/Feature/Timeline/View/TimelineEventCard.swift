import GeografyCore
import GeografyDesign
import SwiftUI

struct TimelineEventCard: View {
    let event: HistoricalEvent
    let country: Country?

    var body: some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.sm) {
                flagSection
                contentSection
                Spacer(minLength: 0)
                eventTypeBadge
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Subviews
private extension TimelineEventCard {
    var flagSection: some View {
        FlagView(countryCode: event.countryCode, height: DesignSystem.Size.lg)
    }

    var contentSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text(event.title)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(2)
            Text(event.formattedDate)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)
            if let country {
                Text(country.name)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
    }

    var eventTypeBadge: some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: event.type.icon)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(eventTypeColor)
            Text(event.type.displayName)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(eventTypeColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }

    var eventTypeColor: Color {
        switch event.type {
        case .independence: DesignSystem.Color.success
        case .nameChange: DesignSystem.Color.orange
        case .borderChange: DesignSystem.Color.blue
        case .formation: DesignSystem.Color.purple
        case .dissolution: DesignSystem.Color.error
        }
    }
}

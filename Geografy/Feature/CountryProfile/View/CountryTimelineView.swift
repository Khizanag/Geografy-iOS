import GeografyDesign
import SwiftUI

struct CountryTimelineView: View {
    let events: [CountryTimelineEvent]

    var body: some View {
        timelineContent
    }
}

// MARK: - Subviews
private extension CountryTimelineView {
    var timelineContent: some View {
        VStack(spacing: 0) {
            ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                timelineRow(event: event, isFirst: index == 0, isLast: index == events.count - 1)
            }
        }
    }

    func timelineRow(event: CountryTimelineEvent, isFirst: Bool, isLast: Bool) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            timelineIndicator(isFirst: isFirst, isLast: isLast)
            eventCard(event: event, isLast: isLast)
        }
    }

    func timelineIndicator(isFirst: Bool, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(isFirst ? .clear : DesignSystem.Color.accent.opacity(0.3))
                .frame(width: 2)

            Circle()
                .fill(DesignSystem.Color.accent)
                .frame(
                    width: DesignSystem.Spacing.sm,
                    height: DesignSystem.Spacing.sm
                )

            Rectangle()
                .fill(isLast ? .clear : DesignSystem.Color.accent.opacity(0.3))
                .frame(width: 2)
        }
        .frame(width: DesignSystem.Spacing.md)
    }

    func eventCard(event: CountryTimelineEvent, isLast: Bool) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(event.year)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.accent)

                Text(event.title)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                Text(event.description)
                    .font(DesignSystem.Font.footnote)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DesignSystem.Spacing.sm)
        }
        .padding(.bottom, isLast ? 0 : DesignSystem.Spacing.xs)
    }
}

import SwiftUI

struct CountryTimelineView: View {
    let events: [CountryTimelineEvent]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                timelineRow(event: event, isLast: index == events.count - 1)
            }
        }
    }
}

// MARK: - Subviews

private extension CountryTimelineView {
    func timelineRow(
        event: CountryTimelineEvent,
        isLast: Bool
    ) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
            timelineIndicator(isLast: isLast)
            eventContent(event: event, isLast: isLast)
        }
    }

    func timelineIndicator(isLast: Bool) -> some View {
        VStack(spacing: 0) {
            Circle()
                .fill(DesignSystem.Color.accent)
                .frame(
                    width: DesignSystem.Spacing.sm,
                    height: DesignSystem.Spacing.sm
                )
            if !isLast {
                Rectangle()
                    .fill(DesignSystem.Color.accent.opacity(0.3))
                    .frame(width: 2)
            }
        }
        .frame(width: DesignSystem.Spacing.md)
    }

    func eventContent(
        event: CountryTimelineEvent,
        isLast: Bool
    ) -> some View {
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

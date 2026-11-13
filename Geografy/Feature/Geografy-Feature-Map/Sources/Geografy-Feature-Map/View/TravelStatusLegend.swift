import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// Names what each travel-status tint and outline on a map means, so status never reads by color alone.
public struct TravelStatusLegend: View {
    // MARK: - Properties
    public let statuses: [TravelStatus]

    // MARK: - Init
    public init(statuses: [TravelStatus] = TravelStatus.allCases) {
        self.statuses = statuses
    }

    // MARK: - Body
    public var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: DesignSystem.Spacing.md) { items }
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) { items }
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .glassEffect(.regular, in: .rect(cornerRadius: DesignSystem.CornerRadius.large))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
    }
}

// MARK: - Subviews
private extension TravelStatusLegend {
    var items: some View {
        ForEach(statuses) { status in
            item(for: status)
        }
    }

    func item(for status: TravelStatus) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            swatch(for: status)
            Image(systemName: status.icon)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(status.color)
                .accessibilityHidden(true)
            Text(status.label)
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
    }

    func swatch(for status: TravelStatus) -> some View {
        Capsule()
            .fill(status.color.opacity(0.35))
            .overlay {
                Capsule()
                    .strokeBorder(
                        status.color,
                        style: StrokeStyle(lineWidth: 1.5, dash: status.mapOutlineDash(lineWidth: 1.5))
                    )
            }
            .frame(width: DesignSystem.Size.md, height: DesignSystem.Size.sm)
            .accessibilityHidden(true)
    }

    var accessibilityDescription: String {
        let entries = statuses.map { status in
            "\(status.label): \(status.mapOutlineDescription)"
        }
        return "Map key. " + entries.joined(separator: ". ")
    }
}

// MARK: - Map Outline
extension TravelStatus {
    /// Visited countries get a solid outline and want-to-visit ones a dashed one, so the two differ by shape too.
    func mapOutlineDash(lineWidth: CGFloat) -> [CGFloat] {
        switch self {
        case .visited: []
        case .wantToVisit: [lineWidth * 3, lineWidth * 2]
        }
    }

    var mapOutlineDescription: String {
        switch self {
        case .visited: "solid outline"
        case .wantToVisit: "dashed outline"
        }
    }
}

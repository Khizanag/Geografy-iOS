#if !os(tvOS)
import Geografy_Core_DesignSystem
import SwiftUI

public struct TimelineSlider: View {
    // MARK: - Properties
    @Binding var selectedYear: Int
    public let range: ClosedRange<Int>
    public let decades: [Int]
    public let eventCountForDecade: (Int) -> Int
    public var accessoryLabel: String?

    // MARK: - Body
    public var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            yearHeader
            sliderControl
            decadeMarkers
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: DesignSystem.CornerRadius.large))
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.bottom, DesignSystem.Spacing.xs)
    }
}

// MARK: - Subviews
private extension TimelineSlider {
    var yearHeader: some View {
        HStack {
            Picker("Year", selection: $selectedYear) {
                ForEach(Array(stride(from: range.upperBound, through: range.lowerBound, by: -1)), id: \.self) { year in
                    Text(String(year)).tag(year)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 120, height: 100)

            Spacer(minLength: 0)

            if let accessoryLabel {
                Text(accessoryLabel)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: accessoryLabel)
            }
        }
    }

    var sliderControl: some View {
        Slider(
            value: yearBinding,
            in: Double(range.lowerBound)...Double(range.upperBound),
            step: 1
        )
        .tint(DesignSystem.Color.accent)
    }

    var decadeMarkers: some View {
        HStack {
            ForEach(majorDecades, id: \.self) { decade in
                decadeLabel(decade)
                if decade != majorDecades.last {
                    Spacer(minLength: 0)
                }
            }
        }
    }

    func decadeLabel(_ decade: Int) -> some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            let count = eventCountForDecade(decade)
            if count > 0 {
                Circle()
                    .fill(DesignSystem.Color.accent.opacity(dotOpacity(for: count)))
                    .frame(
                        width: dotSize(for: count),
                        height: dotSize(for: count)
                    )
            }
            Text(decadeText(decade))
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
    }
}

// MARK: - Helpers
private extension TimelineSlider {
    var yearBinding: Binding<Double> {
        Binding(
            get: { Double(selectedYear) },
            set: { selectedYear = Int($0) }
        )
    }

    var majorDecades: [Int] {
        stride(from: 1_800, through: 2_020, by: 20).map { $0 }
    }

    func decadeText(_ decade: Int) -> String {
        "\(decade.isMultiple(of: 100) ? String(decade) : "'\(decade % 100)")"
    }

    func dotSize(for count: Int) -> CGFloat {
        let clamped = min(count, 20)
        return DesignSystem.Size.xs + CGFloat(clamped)
    }

    func dotOpacity(for count: Int) -> Double {
        let clamped = min(count, 20)
        return 0.3 + Double(clamped) / 30.0
    }
}

#endif

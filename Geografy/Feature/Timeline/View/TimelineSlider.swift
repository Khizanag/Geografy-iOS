import SwiftUI

struct TimelineSlider: View {
    @Binding var selectedYear: Int
    let range: ClosedRange<Int>
    let decades: [Int]
    let eventCountForDecade: (Int) -> Int

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            yearLabel
            sliderControl
            decadeMarkers
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}

// MARK: - Subviews

private extension TimelineSlider {
    var yearLabel: some View {
        Text(String(selectedYear))
            .font(DesignSystem.Font.title)
            .foregroundStyle(DesignSystem.Color.accent)
            .contentTransition(.numericText())
            .animation(.snappy, value: selectedYear)
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
        stride(from: 1800, through: 2020, by: 20).map { $0 }
    }

    func decadeText(_ decade: Int) -> String {
        "\(decade % 100 == 0 ? String(decade) : "'\(decade % 100)")"
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

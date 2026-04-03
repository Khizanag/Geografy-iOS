import Charts
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct WorldBankChartSheet: View {
    public let indicator: StatIndicator
    public let allPoints: [WorldBankService.DataPoint]

    @State private var selectedRange: TimeRange = .thirtyYears
    @State private var selectedPoint: WorldBankService.DataPoint?

    enum TimeRange: String, CaseIterable {
        case tenYears = "10Y"
        case twentyYears = "20Y"
        case thirtyYears = "30Y"
        case all = "All"

        var years: Int? {
            switch self {
            case .tenYears: 10
            case .twentyYears: 20
            case .thirtyYears: 30
            case .all: nil
            }
        }
    }

    public var body: some View {
        scrollContent
            .background(DesignSystem.Color.background)
            .navigationTitle(indicator.title)
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.large])
    }
}

// MARK: - Subviews
private extension WorldBankChartSheet {
    var scrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                headerSection
                rangePicker
                fullChart
                statsSection
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    var filteredPoints: [WorldBankService.DataPoint] {
        guard let years = selectedRange.years,
              let latest = allPoints.last else {
            return allPoints
        }
        let cutoff = latest.year - years
        let filtered = allPoints.filter { $0.year >= cutoff }
        return filtered.count >= 2 ? filtered : allPoints
    }

    var headerSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            if let latest = allPoints.last {
                Text(indicator.format(latest.value))
                    .font(DesignSystem.Font.roundedTitle)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Text("Latest: \(String(latest.year))")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                    Text("·")
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                    Text(indicator.unit)
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
            }
        }
    }

    var rangePicker: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedRange = range
                    }
                } label: {
                    Text(range.rawValue)
                        .font(DesignSystem.Font.caption)
                        .fontWeight(selectedRange == range ? .bold : .regular)
                        .foregroundStyle(
                            selectedRange == range
                                ? DesignSystem.Color.onAccent
                                : DesignSystem.Color.textSecondary
                        )
                        .padding(.horizontal, DesignSystem.Spacing.sm)
                        .padding(.vertical, DesignSystem.Spacing.xxs)
                        .background(
                            selectedRange == range
                                ? DesignSystem.Color.accent
                                : DesignSystem.Color.cardBackground,
                            in: Capsule()
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    var fullChart: some View {
        let points = filteredPoints
        let minYear = points.first?.year ?? 1_990
        let maxYear = points.last?.year ?? 2_023
        return Chart(points) { point in
            AreaMark(
                x: .value("Year", point.year),
                y: .value(indicator.title, point.value)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        DesignSystem.Color.accent.opacity(0.3),
                        DesignSystem.Color.accent.opacity(0.0),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.catmullRom)

            LineMark(
                x: .value("Year", point.year),
                y: .value(indicator.title, point.value)
            )
            .foregroundStyle(DesignSystem.Color.accent)
            .lineStyle(StrokeStyle(lineWidth: 2.5))
            .interpolationMethod(.catmullRom)
        }
        .chartXScale(domain: minYear...maxYear)
        .chartXAxis {
            AxisMarks(values: chartXValues(min: minYear, max: maxYear, count: 5)) { value in
                AxisGridLine()
                    .foregroundStyle(DesignSystem.Color.textTertiary.opacity(0.15))
                AxisValueLabel(centered: true) {
                    if let year = value.as(Int.self) {
                        Text(String(year))
                            .font(DesignSystem.Font.caption2)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { value in
                AxisGridLine()
                    .foregroundStyle(DesignSystem.Color.textTertiary.opacity(0.15))
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        Text(indicator.formatAxisValue(doubleValue))
                            .font(DesignSystem.Font.caption2)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }
                }
            }
        }
        .frame(height: 280)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }

    var statsSection: some View {
        let points = filteredPoints
        return VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Summary")
            summaryGrid(for: points)
        }
    }

    func summaryGrid(for points: [WorldBankService.DataPoint]) -> some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: DesignSystem.Spacing.sm
        ) {
            summaryGridContent(for: points)
        }
    }

    @ViewBuilder
    func summaryGridContent(for points: [WorldBankService.DataPoint]) -> some View {
        if let minimum = points.min(by: { $0.value < $1.value }) {
            statCard(
                label: "Minimum",
                value: indicator.format(minimum.value),
                detail: String(minimum.year),
                color: DesignSystem.Color.blue
            )
        }
        if let maximum = points.max(by: { $0.value < $1.value }) {
            statCard(
                label: "Maximum",
                value: indicator.format(maximum.value),
                detail: String(maximum.year),
                color: DesignSystem.Color.success
            )
        }
        if let first = points.first, let last = points.last, abs(first.value) > 0 {
            let change = (last.value - first.value) / abs(first.value) * 100
            statCard(
                label: "Change",
                value: String(format: "%+.1f%%", change),
                detail: "\(String(first.year))–\(String(last.year))",
                color: change >= 0 ? DesignSystem.Color.success : DesignSystem.Color.error
            )
        }
        statCard(
            label: "Data Points",
            value: "\(points.count)",
            detail: "\(points.first?.year ?? 0)–\(points.last?.year ?? 0)",
            color: DesignSystem.Color.accent
        )
    }

    func statCard(label: String, value: String, detail: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text(label)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            Text(value)
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(detail)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignSystem.Spacing.sm)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    func chartXValues(min minYear: Int, max maxYear: Int, count: Int) -> [Int] {
        guard maxYear > minYear else { return [minYear] }
        let range = maxYear - minYear
        let step = max(1, range / count)
        var values = [minYear]
        var current = minYear + step
        while current < maxYear {
            values.append(current)
            current += step
        }
        if values.last != maxYear {
            values.append(maxYear)
        }
        return values
    }
}

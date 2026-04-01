import Charts
import Geografy_Core_DesignSystem
import SwiftUI
import Geografy_Core_Service

struct WorldBankIndicatorCard: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let indicator: StatIndicator
    let state: WorldBankService.LoadState?
    let cacheAge: Date?

    @State private var pulseOpacity: Double = 0.5
    @State private var showFullChart = false

    var body: some View {
        Button { showFullChart = true } label: {
            CardView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    cardHeader
                    cardContent
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
        .buttonStyle(PressButtonStyle())
        .sheet(isPresented: $showFullChart) {
            if case .loaded(let points) = state {
                WorldBankChartSheet(indicator: indicator, allPoints: points)
            }
        }
    }
}

// MARK: - Subviews
private extension WorldBankIndicatorCard {
    var cardHeader: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: indicator.icon)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(indicator.title)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer()
            Text(indicator.unit)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .padding(.horizontal, DesignSystem.Spacing.xxs)
                .padding(.vertical, 2)
                .background(DesignSystem.Color.cardBackgroundHighlighted)
                .clipShape(Capsule())
        }
    }

    @ViewBuilder
    var cardContent: some View {
        switch state {
        case nil, .loading:
            loadingView
        case .failed:
            errorView
        case .loaded(let points):
            if points.isEmpty {
                emptyView
            } else {
                loadedView(points: points)
            }
        }
    }

    var loadingView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            RoundedRectangle(cornerRadius: 6)
                .fill(DesignSystem.Color.cardBackgroundHighlighted)
                .frame(width: 100, height: 32)
            RoundedRectangle(cornerRadius: 6)
                .fill(DesignSystem.Color.cardBackgroundHighlighted)
                .frame(maxWidth: .infinity)
                .frame(height: 90)
        }
        .opacity(pulseOpacity)
        .animation(
            reduceMotion ? nil : .easeInOut(duration: 0.9).repeatForever(autoreverses: true),
            value: pulseOpacity
        )
        .onAppear { pulseOpacity = 1.0 }
    }

    var errorView: some View {
        HStack {
            Spacer()
            VStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: "exclamationmark.circle")
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                Text("Data unavailable")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            Spacer()
        }
        .frame(height: 90)
    }

    var emptyView: some View {
        HStack {
            Spacer()
            VStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: "chart.xyaxis.line")
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                Text("No historical data")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            Spacer()
        }
        .frame(height: 90)
    }

    func loadedView(points: [WorldBankService.DataPoint]) -> some View {
        let recentPoints = recentData(from: points, years: 30)
        return VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            latestValueRow(points: points)
            lineChart(points: recentPoints)
            footerRow(points: recentPoints)
        }
    }

    func recentData(from points: [WorldBankService.DataPoint], years: Int) -> [WorldBankService.DataPoint] {
        guard let latest = points.last else { return points }
        let cutoff = latest.year - years
        let filtered = points.filter { $0.year >= cutoff }
        return filtered.count >= 2 ? filtered : points
    }
}

// MARK: - Loaded Subviews
private extension WorldBankIndicatorCard {
    func latestValueRow(points: [WorldBankService.DataPoint]) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: DesignSystem.Spacing.sm) {
            if let latest = points.last {
                Text(indicator.format(latest.value))
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text("(\(String(latest.year)))")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            Spacer()
            trendBadge(points: points)
        }
    }

    @ViewBuilder
    func trendBadge(points: [WorldBankService.DataPoint]) -> some View {
        if let latest = points.last,
           let past = points.last(where: { $0.year <= latest.year - 10 }),
           abs(past.value) > 0 {
            let change = (latest.value - past.value) / abs(past.value) * 100
            let isPositive = change > 0
            let isGood = isPositive == indicator.higherIsBetter
            let color = isGood ? DesignSystem.Color.success : DesignSystem.Color.error

            HStack(spacing: 3) {
                Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                    .font(DesignSystem.Font.nano.bold())
                Text(String(format: "%.0f%%", abs(change)))
                    .font(DesignSystem.Font.caption2)
                    .fontWeight(.semibold)
                Text("10yr")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(color.opacity(0.7))
            }
            .foregroundStyle(color)
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
        }
    }

    func lineChart(points: [WorldBankService.DataPoint]) -> some View {
        let minYear = points.first?.year ?? 1990
        let maxYear = points.last?.year ?? 2023
        return Chart(points) { point in
            AreaMark(
                x: .value("Year", point.year),
                y: .value(indicator.title, point.value)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        DesignSystem.Color.accent.opacity(0.25),
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
            .lineStyle(StrokeStyle(lineWidth: 2))
            .interpolationMethod(.catmullRom)
        }
        .chartXScale(domain: minYear...maxYear)
        .chartXAxis {
            AxisMarks(values: chartXValues(min: minYear, max: maxYear, count: 3)) { value in
                AxisGridLine()
                    .foregroundStyle(DesignSystem.Color.textTertiary.opacity(0.2))
                AxisValueLabel(centered: true) {
                    if let year = value.as(Int.self) {
                        Text(String(year))
                            .font(DesignSystem.Font.caption2)
                            .foregroundStyle(DesignSystem.Color.textTertiary)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 3)) { value in
                AxisGridLine()
                    .foregroundStyle(DesignSystem.Color.textTertiary.opacity(0.2))
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        Text(indicator.formatAxisValue(doubleValue))
                            .font(DesignSystem.Font.nano)
                            .foregroundStyle(DesignSystem.Color.textTertiary)
                    }
                }
            }
        }
        .frame(height: 100)
    }

    func footerRow(points: [WorldBankService.DataPoint]) -> some View {
        HStack {
            Text("\(String(points.first?.year ?? 1960)) – \(String(points.last?.year ?? 2023))")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
            Spacer()
            if let age = cacheAge {
                HStack(spacing: 3) {
                    Image(systemName: "arrow.clockwise")
                        .font(DesignSystem.Font.pico)
                    Text(formattedCacheAge(age))
                }
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
            }
        }
    }
}

// MARK: - Helpers
private extension WorldBankIndicatorCard {
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

    func formattedCacheAge(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 3600 {
            return "Just now"
        } else if interval < 86400 {
            return "\(Int(interval / 3600))h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}

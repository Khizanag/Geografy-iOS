import SwiftUI

private struct WorldRecord: Identifiable {
    let id = UUID()
    let emoji: String
    let title: String
    let value: String
    let country: String
    let gradientColors: [Color]
}

struct HomeWorldRecordsCard: View {
    private let records: [WorldRecord] = [
        WorldRecord(
            emoji: "🌏",
            title: "Largest Country",
            value: "17.1M km²",
            country: "Russia",
            gradientColors: [Color(hex: "1565C0"), Color(hex: "0D47A1")]
        ),
        WorldRecord(
            emoji: "👥",
            title: "Most Populous",
            value: "1.4B people",
            country: "India",
            gradientColors: [Color(hex: "E65100"), Color(hex: "BF360C")]
        ),
        WorldRecord(
            emoji: "🏔️",
            title: "Highest Point",
            value: "8,849 m",
            country: "Nepal / China",
            gradientColors: [Color(hex: "1B5E20"), Color(hex: "2E7D32")]
        ),
        WorldRecord(
            emoji: "🤏",
            title: "Smallest Country",
            value: "0.44 km²",
            country: "Vatican City",
            gradientColors: [Color(hex: "4A148C"), Color(hex: "6A1B9A")]
        ),
        WorldRecord(
            emoji: "🌊",
            title: "Longest Coastline",
            value: "202,080 km",
            country: "Canada",
            gradientColors: [Color(hex: "006064"), Color(hex: "00838F")]
        ),
        WorldRecord(
            emoji: "🏜️",
            title: "Largest Desert",
            value: "9.2M km²",
            country: "Algeria",
            gradientColors: [Color(hex: "F57F17"), Color(hex: "E65100")]
        ),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionHeader
            recordsScroll
        }
    }
}

// MARK: - Subviews

private extension HomeWorldRecordsCard {
    var sectionHeader: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            RoundedRectangle(cornerRadius: 2)
                .fill(DesignSystem.Color.accent)
                .frame(width: 3, height: 18)
            Text("World Records")
                .font(DesignSystem.Font.title2)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    var recordsScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(records) { record in
                    recordTile(record)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.xs)
        }
    }

    func recordTile(_ record: WorldRecord) -> some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: record.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text(record.emoji)
                .font(.system(size: 48))
                .opacity(0.18)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .offset(x: 6, y: -6)
                .clipped()
            VStack(alignment: .leading, spacing: 3) {
                Text(record.emoji)
                    .font(.system(size: 22))
                Text(record.title)
                    .font(DesignSystem.Font.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.75))
                Text(record.value)
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Text(record.country)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(.white.opacity(0.65))
                    .lineLimit(1)
            }
            .padding(DesignSystem.Spacing.sm)
        }
        .frame(width: 148, height: 148)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
    }
}

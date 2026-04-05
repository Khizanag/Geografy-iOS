import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

private struct WorldRecordTile: Identifiable {
    let id = UUID()
    let emoji: String
    let title: String
    let value: String
    let country: String
    let gradientColors: [Color]
}

struct HomeWorldRecordsCard: View {
    // MARK: - Properties
    let onSeeAll: (() -> Void)?

    // MARK: - Init
    init(onSeeAll: (() -> Void)? = nil) {
        self.onSeeAll = onSeeAll
    }

    private let records: [WorldRecordTile] = [
        WorldRecordTile(
            emoji: "🌏", title: "Largest Country", value: "17.1M km²",
            country: "Russia",
            gradientColors: [Color(hex: "1565C0"), Color(hex: "0D47A1")]
        ),
        WorldRecordTile(
            emoji: "👥", title: "Most Populous", value: "1.4B people",
            country: "India",
            gradientColors: [Color(hex: "E65100"), Color(hex: "BF360C")]
        ),
        WorldRecordTile(
            emoji: "🏔️", title: "Highest Point", value: "8,849 m",
            country: "Nepal / China",
            gradientColors: [Color(hex: "1B5E20"), Color(hex: "2E7D32")]
        ),
        WorldRecordTile(
            emoji: "🤏", title: "Smallest Country", value: "0.44 km²",
            country: "Vatican City",
            gradientColors: [Color(hex: "4A148C"), Color(hex: "6A1B9A")]
        ),
        WorldRecordTile(
            emoji: "🌊", title: "Longest Coastline", value: "202,080 km",
            country: "Canada",
            gradientColors: [Color(hex: "006064"), Color(hex: "00838F")]
        ),
        WorldRecordTile(
            emoji: "🏜️", title: "Largest Desert", value: "9.2M km²",
            country: "Sahara, Africa",
            gradientColors: [Color(hex: "F57F17"), Color(hex: "E65100")]
        ),
        WorldRecordTile(
            emoji: "💰", title: "Highest GDP/Capita", value: "$145K",
            country: "Luxembourg",
            gradientColors: [Color(hex: "00695C"), Color(hex: "004D40")]
        ),
        WorldRecordTile(
            emoji: "🗣️", title: "Most Languages", value: "840+",
            country: "Papua New Guinea",
            gradientColors: [Color(hex: "AD1457"), Color(hex: "880E4F")]
        ),
        WorldRecordTile(
            emoji: "🏝️", title: "Most Islands", value: "17,508",
            country: "Indonesia",
            gradientColors: [Color(hex: "0277BD"), Color(hex: "01579B")]
        ),
        WorldRecordTile(
            emoji: "🌡️", title: "Hottest Recorded", value: "56.7°C",
            country: "USA (Death Valley)",
            gradientColors: [Color(hex: "D84315"), Color(hex: "BF360C")]
        ),
        WorldRecordTile(
            emoji: "❄️", title: "Coldest Recorded", value: "−89.2°C",
            country: "Antarctica",
            gradientColors: [Color(hex: "283593"), Color(hex: "1A237E")]
        ),
        WorldRecordTile(
            emoji: "🏞️", title: "Longest River", value: "6,650 km",
            country: "Nile, Africa",
            gradientColors: [Color(hex: "2E7D32"), Color(hex: "1B5E20")]
        ),
        WorldRecordTile(
            emoji: "🌋", title: "Most Volcanoes", value: "130 active",
            country: "Indonesia",
            gradientColors: [Color(hex: "B71C1C"), Color(hex: "8E1616")]
        ),
        WorldRecordTile(
            emoji: "🦁", title: "Most Biodiversity", value: "Top 1",
            country: "Brazil",
            gradientColors: [Color(hex: "33691E"), Color(hex: "1B5E20")]
        ),
        WorldRecordTile(
            emoji: "🏗️", title: "Most Dense", value: "26K/km²",
            country: "Monaco",
            gradientColors: [Color(hex: "5D4037"), Color(hex: "3E2723")]
        ),
    ]

    // MARK: - Body
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
        HStack {
            SectionHeaderView(title: "World Records", icon: "trophy.fill")
            Spacer()
            if let onSeeAll {
                Button(action: onSeeAll) {
                    Text("See All")
                        .font(DesignSystem.Font.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.accent)
                }
                .buttonStyle(.plain)
                .padding(.trailing, DesignSystem.Spacing.xs)
            }
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

    func recordTile(_ record: WorldRecordTile) -> some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: record.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text(record.emoji)
                .font(DesignSystem.Font.displaySmall)
                .opacity(0.18)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .offset(x: 6, y: -6)
                .clipped()
            VStack(alignment: .leading, spacing: 3) {
                Text(record.emoji)
                    .font(DesignSystem.Font.iconDefault)
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
                    .lineLimit(2)
            }
            .padding(DesignSystem.Spacing.sm)
        }
        .frame(width: 148, height: 148)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
    }
}

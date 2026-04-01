import Geografy_Core_Navigation
import Geografy_Core_Common
import Geografy_Core_Service
import Geografy_Core_DesignSystem
import SwiftUI

struct WorldRecordsScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Navigator.self) private var coordinator
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var records: [WorldRecord] = []
    @State private var blobAnimating = false

    private let worldRecordsService = WorldRecordsService()

    var body: some View {
        scrollContent
            .background { ambientBlobs }
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle("World Records")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                records = worldRecordsService.computeRecords(from: countryDataService.countries)
            }
            .onAppear { startBlobAnimation() }
    }
}

// MARK: - Subviews
private extension WorldRecordsScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                ForEach(WorldRecordCategory.allCases, id: \.rawValue) { category in
                    let categoryRecords = records.filter { $0.category == category }
                    if !categoryRecords.isEmpty {
                        categorySection(category: category, records: categoryRecords)
                    }
                }
            }
            .padding(.vertical, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
    }

    func categorySection(category: WorldRecordCategory, records: [WorldRecord]) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: category.displayName, icon: category.icon)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(records) { record in
                    recordRow(record)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }

    func recordRow(_ record: WorldRecord) -> some View {
        let country = countryDataService.country(for: record.countryCode)
        return Button {
            if let found = country {
                coordinator.push(.countryDetail(found))
            }
        } label: {
            CardView {
                recordRowContent(record: record, country: country)
            }
        }
        .buttonStyle(PressButtonStyle())
        .disabled(country == nil)
    }

    func recordRowContent(record: WorldRecord, country: Country?) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            trophyIcon(for: record.category)
            recordInfo(record: record)
            Spacer()
            if let country {
                FlagView(countryCode: country.code, height: 28)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(record.title): \(record.countryName), \(record.value)")
    }

    func trophyIcon(for category: WorldRecordCategory) -> some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Color.accent.opacity(0.12))
                .frame(width: 44, height: 44)
            Image(systemName: category.icon)
                .font(DesignSystem.Font.iconSmall)
                .foregroundStyle(DesignSystem.Color.accent)
        }
        .accessibilityHidden(true)
    }

    func recordInfo(record: WorldRecord) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(record.title)
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            Text(record.countryName)
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(1)
            Text(record.value)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.accent)
                .fontWeight(.semibold)
        }
    }

    var ambientBlobs: some View {
        ZStack {
            blobEllipse(color: DesignSystem.Color.accent, opacity: 0.25, offset: (-100, -200), animates: blobAnimating)
            blobEllipse(color: DesignSystem.Color.indigo, opacity: 0.20, offset: (160, 300), animates: !blobAnimating)
        }
        .allowsHitTesting(false)
        .animation(reduceMotion ? nil : .easeInOut(duration: 6).repeatForever(autoreverses: true), value: blobAnimating)
    }

    func blobEllipse(color: Color, opacity: Double, offset: (CGFloat, CGFloat), animates: Bool) -> some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [color.opacity(opacity), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 200
                )
            )
            .frame(width: 400, height: 320)
            .blur(radius: 40)
            .offset(x: offset.0, y: offset.1)
            .scaleEffect(animates ? 1.08 : 0.92)
    }
}

// MARK: - Actions
private extension WorldRecordsScreen {
    func startBlobAnimation() {
        blobAnimating = true
    }
}

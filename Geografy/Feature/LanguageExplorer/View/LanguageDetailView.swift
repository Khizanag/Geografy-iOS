import SwiftUI
import GeografyDesign

struct LanguageDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let language: Language
    let maxSpeakers: Int

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                headerSection
                speakerSection
                metadataSection
                countriesSection
                funFactSection
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
        }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle(language.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CircleCloseButton { dismiss() }
            }
        }
    }
}

// MARK: - Subviews
private extension LanguageDetailView {
    var headerSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(language.nativeName)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(language.name)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    var speakerSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Speakers", icon: "person.3.fill")
            CardView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    HStack {
                        Text("\(language.speakerCount)M")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                        Spacer()
                        Text("native speakers")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }
                    speakerBar
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
    }

    var speakerBar: some View {
        GeometryReader { geometryReader in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(DesignSystem.Color.blue.opacity(0.15))
                    .frame(height: 10)
                RoundedRectangle(cornerRadius: 4)
                    .fill(DesignSystem.Color.blue)
                    .frame(
                        width: geometryReader.size.width * speakerRatio,
                        height: 10
                    )
            }
        }
        .frame(height: 10)
    }

    var metadataSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Details", icon: "info.circle.fill")
            HStack(spacing: DesignSystem.Spacing.sm) {
                metaTile(label: "Family", value: language.family, icon: "chart.bar.fill")
                metaTile(label: "Script", value: language.script, icon: "character.cursor.ibeam")
            }
        }
    }

    func metaTile(label: String, value: String, icon: String) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Label(label, systemImage: icon)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                Text(value)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .minimumScaleFactor(0.75)
                    .lineLimit(2)
            }
            .padding(DesignSystem.Spacing.sm)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var countriesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Official In", icon: "flag.fill")
            CardView {
                LazyVStack(spacing: 0) {
                    ForEach(language.countries.indices, id: \.self) { index in
                        countryFlagRow(code: language.countries[index])
                        if index < language.countries.count - 1 {
                            Divider()
                        }
                    }
                }
                .padding(.vertical, DesignSystem.Spacing.xs)
            }
        }
    }

    func countryFlagRow(code: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            FlagView(countryCode: code, height: 24)
            Text(code)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }

    var funFactSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Fun Fact", icon: "lightbulb.fill")
            CardView {
                HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "lightbulb.fill")
                        .font(DesignSystem.Font.callout)
                        .foregroundStyle(DesignSystem.Color.warning)
                        .padding(.top, 2)
                    Text(language.funFact)
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
    }
}

// MARK: - Helpers
private extension LanguageDetailView {
    var speakerRatio: Double {
        guard maxSpeakers > 0 else { return 0 }
        return min(Double(language.speakerCount) / Double(maxSpeakers), 1.0)
    }
}

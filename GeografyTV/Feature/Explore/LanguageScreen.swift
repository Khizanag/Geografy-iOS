import Geografy_Core_DesignSystem
import Geografy_Feature_LanguageExplorer
import SwiftUI

struct LanguageScreen: View {
    @State private var service = LanguageService()
    @State private var selectedFamily: String?

    private var displayedLanguages: [Language] {
        guard let selectedFamily else { return service.languages }
        return service.languages(in: selectedFamily)
    }

    var body: some View {
        // swiftlint:disable:next closure_body_length
        List {
            Section {
                Picker("Family", selection: $selectedFamily) {
                    Text("All").tag(nil as String?)
                    ForEach(service.families, id: \.self) { family in
                        Text(family)
                            .tag(family as String?)
                    }
                }
            }

            Section("\(displayedLanguages.count) languages") {
                ForEach(displayedLanguages) { language in
                    HStack(spacing: DesignSystem.Spacing.lg) {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                            Text(language.name)
                                .font(DesignSystem.Font.system(size: 22, weight: .semibold))

                            Text(language.nativeName)
                                .font(DesignSystem.Font.system(size: 22))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(language.speakerCount)M speakers")
                                .font(DesignSystem.Font.system(size: 22, weight: .semibold))
                                .foregroundStyle(DesignSystem.Color.accent)

                            Text(language.family)
                                .font(DesignSystem.Font.system(size: 22))
                                .foregroundStyle(DesignSystem.Color.textTertiary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Languages")
    }
}

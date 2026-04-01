import Geografy_Core_DesignSystem
import SwiftUI
import Geografy_Feature_LanguageExplorer

struct LanguageScreen: View {
    @State private var service = LanguageService()
    @State private var selectedFamily: String?

    private var displayedLanguages: [Language] {
        guard let selectedFamily else { return service.languages }
        return service.languages(in: selectedFamily)
    }

    var body: some View {
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
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(language.name)
                                .font(.system(size: 22, weight: .semibold))

                            Text(language.nativeName)
                                .font(.system(size: 22))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(language.speakerCount)M speakers")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(DesignSystem.Color.accent)

                            Text(language.family)
                                .font(.system(size: 22))
                                .foregroundStyle(DesignSystem.Color.textTertiary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Languages")
    }
}

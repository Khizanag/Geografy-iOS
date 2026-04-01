import Geografy_Core_DesignSystem
import SwiftUI

struct GeographyFeaturesScreen: View {
    @State private var selectedType: GeographyFeatureType = .mountain

    private let service = GeographyFeaturesService()

    private var displayedFeatures: [GeographyFeature] {
        service.features(for: selectedType)
    }

    var body: some View {
        List {
            Section {
                Picker("Type", selection: $selectedType) {
                    ForEach(GeographyFeatureType.allCases, id: \.self) { type in
                        Label(type.displayName, systemImage: type.icon)
                            .tag(type)
                    }
                }
            }

            Section("\(displayedFeatures.count) features") {
                ForEach(displayedFeatures) { feature in
                    HStack(spacing: 20) {
                        Image(systemName: selectedType.icon)
                            .font(.system(size: 22))
                            .foregroundStyle(DesignSystem.Color.accent)
                            .frame(width: 36)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(feature.name)
                                .font(.system(size: 22, weight: .semibold))

                            Text(feature.description)
                                .font(.system(size: 22))
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text(feature.measurementLabel)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(DesignSystem.Color.accent)

                            Text(feature.measurementUnit)
                                .font(.system(size: 22))
                                .foregroundStyle(DesignSystem.Color.textTertiary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Geography Features")
    }
}

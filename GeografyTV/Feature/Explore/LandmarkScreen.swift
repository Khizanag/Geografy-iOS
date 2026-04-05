import Geografy_Core_DesignSystem
import Geografy_Feature_LandmarkGallery
import SwiftUI

struct LandmarkScreen: View {
    @State private var selectedCategory: LandmarkCategory?

    private let service = LandmarkGalleryService()

    private var displayedLandmarks: [Landmark] {
        service.landmarks(in: selectedCategory)
    }

    var body: some View {
        List {
            Section {
                Picker("Category", selection: $selectedCategory) {
                    Text("All").tag(nil as LandmarkCategory?)
                    ForEach(LandmarkCategory.allCases, id: \.self) { category in
                        Text(category.displayName)
                            .tag(category as LandmarkCategory?)
                    }
                }
            }

            Section {
                ForEach(displayedLandmarks) { landmark in
                    NavigationLink {
                        LandmarkDetailScreen(landmark: landmark)
                    } label: {
                        landmarkRow(landmark)
                    }
                }
            }
        }
        .navigationTitle("Landmarks")
    }
}

// MARK: - Row
private extension LandmarkScreen {
    func landmarkRow(_ landmark: Landmark) -> some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: landmark.symbolName)
                .font(DesignSystem.Font.system(size: 28))
                .foregroundStyle(Color(hex: landmark.accentColor))
                .frame(width: 44)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(landmark.name)
                    .font(DesignSystem.Font.system(size: 22, weight: .semibold))

                HStack(spacing: DesignSystem.Spacing.xs) {
                    FlagView(countryCode: landmark.countryCode, height: 20)

                    Text(landmark.city)
                        .font(DesignSystem.Font.system(size: 22))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if landmark.isUNESCO {
                Image(systemName: "star.fill")
                    .font(DesignSystem.Font.system(size: 22))
                    .foregroundStyle(DesignSystem.Color.warning)
            }
        }
    }
}

// MARK: - Detail
struct LandmarkDetailScreen: View {
    let landmark: Landmark

    private var accentSwiftUIColor: Color {
        Color(hex: landmark.accentColor)
    }

    var body: some View {
        // swiftlint:disable:next closure_body_length
        List {
            Section {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        Image(systemName: landmark.symbolName)
                            .font(DesignSystem.Font.system(size: 44))
                            .foregroundStyle(accentSwiftUIColor)

                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                            Text(landmark.name)
                                .font(DesignSystem.Font.system(size: 32, weight: .bold))

                            HStack(spacing: DesignSystem.Spacing.xs) {
                                FlagView(countryCode: landmark.countryCode, height: 24)
                                Text(landmark.city)
                                    .font(DesignSystem.Font.system(size: 20))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Text(landmark.description)
                        .font(DesignSystem.Font.system(size: 20))
                        .foregroundStyle(.secondary)
                }
            }

            Section("Details") {
                if let year = landmark.yearBuilt {
                    HStack {
                        Label("Year Built", systemImage: "calendar")
                        Spacer()
                        Text("\(year)")
                            .foregroundStyle(.secondary)
                    }
                }

                HStack {
                    Label("Category", systemImage: "tag")
                    Spacer()
                    Text(landmark.category.displayName)
                        .foregroundStyle(.secondary)
                }

                if landmark.isUNESCO {
                    Label("UNESCO World Heritage Site", systemImage: "star.fill")
                        .foregroundStyle(DesignSystem.Color.warning)
                }
            }

            Section("Fun Fact") {
                Text(landmark.funFact)
                    .font(DesignSystem.Font.system(size: 20))
            }
        }
        .navigationTitle(landmark.name)
    }
}

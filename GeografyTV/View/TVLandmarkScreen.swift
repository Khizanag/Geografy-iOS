import SwiftUI

struct TVLandmarkScreen: View {
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
                        TVLandmarkDetailScreen(landmark: landmark)
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

private extension TVLandmarkScreen {
    func landmarkRow(_ landmark: Landmark) -> some View {
        HStack(spacing: 20) {
            Image(systemName: landmark.symbolName)
                .font(.system(size: 28))
                .foregroundStyle(Color(hex: landmark.accentColor) ?? DesignSystem.Color.accent)
                .frame(width: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(landmark.name)
                    .font(.system(size: 22, weight: .semibold))

                HStack(spacing: 8) {
                    FlagView(countryCode: landmark.countryCode, height: 20)

                    Text(landmark.city)
                        .font(.system(size: 18))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if landmark.isUNESCO {
                Image(systemName: "star.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(DesignSystem.Color.warning)
            }
        }
    }
}

// MARK: - Detail

struct TVLandmarkDetailScreen: View {
    let landmark: Landmark

    private var accentSwiftUIColor: Color {
        Color(hex: landmark.accentColor) ?? DesignSystem.Color.accent
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 16) {
                        Image(systemName: landmark.symbolName)
                            .font(.system(size: 44))
                            .foregroundStyle(accentSwiftUIColor)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(landmark.name)
                                .font(.system(size: 32, weight: .bold))

                            HStack(spacing: 8) {
                                FlagView(countryCode: landmark.countryCode, height: 24)
                                Text(landmark.city)
                                    .font(.system(size: 20))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Text(landmark.description)
                        .font(.system(size: 20))
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
                    .font(.system(size: 20))
            }
        }
        .navigationTitle(landmark.name)
    }
}

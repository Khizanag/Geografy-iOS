import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import Geografy_Feature_CultureExplorer
import SwiftUI

struct CultureScreen: View {
    let countryDataService: CountryDataService

    private let service = CultureService()

    var body: some View {
        List(service.facts) { fact in
            NavigationLink {
                CultureDetailView(
                    country: countryDataService.countries.first { $0.code == fact.countryCode },
                    fact: fact
                )
            } label: {
                HStack(spacing: DesignSystem.Spacing.lg) {
                    FlagView(countryCode: fact.countryCode, height: 36)

                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                        Text(fact.countryCode)
                            .font(DesignSystem.Font.system(size: 22, weight: .semibold))

                        Text(fact.cuisine)
                            .font(DesignSystem.Font.system(size: 22))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
        }
        .navigationTitle("Culture Explorer")
    }
}

// MARK: - Detail
struct CultureDetailView: View {
    let country: Country?
    let fact: CultureFact

    var body: some View {
        // swiftlint:disable:next closure_body_length
        List {
            Section {
                HStack(spacing: DesignSystem.Spacing.lg) {
                    FlagView(countryCode: fact.countryCode, height: 60)
                    Text(country?.name ?? fact.countryCode)
                        .font(DesignSystem.Font.system(size: 32, weight: .bold))
                }
            }

            if !fact.cuisine.isEmpty {
                Section("Cuisine") {
                    Text(fact.cuisine)
                        .font(DesignSystem.Font.system(size: 20))
                }
            }

            if !fact.music.isEmpty {
                Section("Music") {
                    Text(fact.music)
                        .font(DesignSystem.Font.system(size: 20))
                }
            }

            if !fact.dance.isEmpty {
                Section("Dance") {
                    Text(fact.dance)
                        .font(DesignSystem.Font.system(size: 20))
                }
            }

            if !fact.festival.isEmpty {
                Section("Festival") {
                    Text(fact.festival)
                        .font(DesignSystem.Font.system(size: 20))
                }
            }

            if !fact.sport.isEmpty {
                Section("Sport") {
                    Text(fact.sport)
                        .font(DesignSystem.Font.system(size: 20))
                }
            }

            if !fact.greeting.isEmpty {
                Section("Greeting") {
                    Text(fact.greeting)
                        .font(DesignSystem.Font.system(size: 20))
                }
            }

            if !fact.funFact.isEmpty {
                Section("Fun Fact") {
                    Text(fact.funFact)
                        .font(DesignSystem.Font.system(size: 20))
                }
            }
        }
        .navigationTitle(country?.name ?? fact.countryCode)
    }
}

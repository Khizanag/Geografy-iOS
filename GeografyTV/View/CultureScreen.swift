import Geografy_Core_Service
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI
import Geografy_Feature_CultureExplorer

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
                HStack(spacing: 20) {
                    FlagView(countryCode: fact.countryCode, height: 36)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(fact.countryCode)
                            .font(.system(size: 22, weight: .semibold))

                        Text(fact.cuisine)
                            .font(.system(size: 22))
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
        List {
            Section {
                HStack(spacing: 20) {
                    FlagView(countryCode: fact.countryCode, height: 60)
                    Text(country?.name ?? fact.countryCode)
                        .font(.system(size: 32, weight: .bold))
                }
            }

            if !fact.cuisine.isEmpty {
                Section("Cuisine") {
                    Text(fact.cuisine)
                        .font(.system(size: 20))
                }
            }

            if !fact.music.isEmpty {
                Section("Music") {
                    Text(fact.music)
                        .font(.system(size: 20))
                }
            }

            if !fact.dance.isEmpty {
                Section("Dance") {
                    Text(fact.dance)
                        .font(.system(size: 20))
                }
            }

            if !fact.festival.isEmpty {
                Section("Festival") {
                    Text(fact.festival)
                        .font(.system(size: 20))
                }
            }

            if !fact.sport.isEmpty {
                Section("Sport") {
                    Text(fact.sport)
                        .font(.system(size: 20))
                }
            }

            if !fact.greeting.isEmpty {
                Section("Greeting") {
                    Text(fact.greeting)
                        .font(.system(size: 20))
                }
            }

            if !fact.funFact.isEmpty {
                Section("Fun Fact") {
                    Text(fact.funFact)
                        .font(.system(size: 20))
                }
            }
        }
        .navigationTitle(country?.name ?? fact.countryCode)
    }
}

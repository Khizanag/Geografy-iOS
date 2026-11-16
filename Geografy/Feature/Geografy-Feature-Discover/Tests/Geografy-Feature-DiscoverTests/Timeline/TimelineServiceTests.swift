import Foundation
import Geografy_Core_Common
@testable import Geografy_Feature_Discover
import Testing

@Suite("TimelineService")
struct TimelineServiceTests {
    @Test("Counts events per decade for the filter")
    func decadeCounts() {
        let service = Self.makeService()

        #expect(service.eventCount(forDecade: 1_990, filter: TimelineFilter(), countries: Self.countries) == 3)
        #expect(service.eventCount(forDecade: 1_960, filter: TimelineFilter(), countries: Self.countries) == 1)
        #expect(service.eventCount(forDecade: 1_800, filter: TimelineFilter(), countries: Self.countries) == 0)
    }

    @Test("A continent filter keeps only events of that continent's countries")
    func continentFilter() {
        let service = Self.makeService()
        let filter = TimelineFilter(continent: .africa)

        #expect(service.eventCount(forDecade: 1_990, filter: filter, countries: Self.countries) == 1)
        #expect(service.events(for: 1_991, filter: filter, countries: Self.countries).isEmpty)
        #expect(service.events(for: 1_993, filter: filter, countries: Self.countries).map(\.countryCode) == ["ER"])
    }

    @Test("An event for a country that isn't listed never matches a continent filter")
    func unknownCountryFailsContinentFilter() {
        let service = Self.makeService()
        let filter = TimelineFilter(continent: .europe)

        #expect(service.events(for: 1_991, filter: filter, countries: Self.countries).map(\.countryCode) == ["GE"])
    }

    @Test("Counts follow a changed filter rather than the first one asked")
    func countsFollowFilter() {
        let service = Self.makeService()
        let typed = TimelineFilter(eventType: .formation)

        _ = service.eventCount(forDecade: 1_990, filter: TimelineFilter(), countries: Self.countries)

        #expect(service.eventCount(forDecade: 1_990, filter: typed, countries: Self.countries) == 0)
        #expect(service.eventCount(forDecade: 1_960, filter: typed, countries: Self.countries) == 1)
    }

    @Test("Today's events are those on this month and day, oldest first")
    func todayEvents() throws {
        let today = Calendar.current.dateComponents([.month, .day], from: Date())
        let month = try #require(today.month)
        let day = try #require(today.day)
        let service = TimelineService()
        service.setEvents([
            Self.event("GE", year: 2_000, month: month, day: day),
            Self.event("ER", year: 1_900, month: month, day: day),
            Self.event("SG", year: 1_950, month: month, day: nil),
        ])

        #expect(service.todayEvents(countries: Self.countries).map(\.year) == [1_900, 2_000])
    }

    @Test("Loading again keeps the events already there")
    func loadKeepsEvents() {
        let service = Self.makeService()

        service.loadEvents()

        #expect(service.events.count == 5)
    }
}

// MARK: - Fixtures
private extension TimelineServiceTests {
    static let countries = [
        makeCountry(code: "GE", continent: .europe),
        makeCountry(code: "ER", continent: .africa),
        makeCountry(code: "SG", continent: .asia),
    ]

    static func makeService() -> TimelineService {
        let service = TimelineService()
        service.setEvents([
            event("GE", year: 1_991),
            event("XX", year: 1_991),
            event("ER", year: 1_993),
            event("SG", year: 1_965, type: .formation),
            event("SG", year: 2_005),
        ])
        return service
    }

    static func event(
        _ code: String,
        year: Int,
        month: Int? = nil,
        day: Int? = nil,
        type: HistoricalEvent.EventType = .independence
    ) -> HistoricalEvent {
        HistoricalEvent(
            year: year,
            month: month,
            day: day,
            countryCode: code,
            type: type,
            title: code,
            description: ""
        )
    }

    static func makeCountry(code: String, continent: Country.Continent) -> Country {
        Country(
            code: code,
            name: code,
            capital: "",
            flagEmoji: "",
            continent: continent,
            area: 1,
            population: 1,
            populationDensity: 1,
            currency: Country.Currency(name: "", code: ""),
            languages: [],
            formOfGovernment: "",
            gdp: nil,
            gdpPerCapita: nil,
            gdpPPP: nil,
            organizations: []
        )
    }
}

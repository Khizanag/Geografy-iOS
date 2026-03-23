import Foundation
import Observation

// MARK: - Stat Category

enum StatCategory: String, CaseIterable, Identifiable {
    case economy
    case demographics
    case education
    case health
    case technology

    var id: String { rawValue }

    var title: String {
        switch self {
        case .economy: "Economy"
        case .demographics: "Demographics"
        case .education: "Education"
        case .health: "Health"
        case .technology: "Technology"
        }
    }

    var icon: String {
        switch self {
        case .economy: "chart.line.uptrend.xyaxis"
        case .demographics: "person.3"
        case .education: "book"
        case .health: "heart.text.clipboard"
        case .technology: "wifi"
        }
    }

    var indicators: [StatIndicator] {
        switch self {
        case .economy: [.gdp, .gdpPerCapita, .gdpGrowth, .inflation, .unemployment, .trade]
        case .demographics: [.population, .lifeExpectancy, .fertilityRate, .urbanPopulation, .populationGrowth, .birthRate, .deathRate]
        case .education: [.literacyRate, .educationSpending, .primaryEnrollment, .secondaryEnrollment, .tertiaryEnrollment]
        case .health: [.infantMortality, .healthExpenditure]
        case .technology: [.internetUsers, .mobileSubscriptions, .electricityAccess, .co2Emissions]
        }
    }
}

// MARK: - Stat Indicator

enum StatIndicator: String, CaseIterable, Identifiable {
    // Economy
    case gdp = "NY.GDP.MKTP.CD"
    case gdpPerCapita = "NY.GDP.PCAP.CD"
    case gdpGrowth = "NY.GDP.MKTP.KD.ZG"
    case inflation = "FP.CPI.TOTL.ZG"
    case unemployment = "SL.UEM.TOTL.ZS"
    case trade = "NE.TRD.GNFS.ZS"

    // Demographics
    case population = "SP.POP.TOTL"
    case lifeExpectancy = "SP.DYN.LE00.IN"
    case fertilityRate = "SP.DYN.TFRT.IN"
    case urbanPopulation = "SP.URB.TOTL.IN.ZS"
    case populationGrowth = "SP.POP.GROW"
    case birthRate = "SP.DYN.CBRT.IN"
    case deathRate = "SP.DYN.CDRT.IN"

    // Education
    case literacyRate = "SE.ADT.LITR.ZS"
    case educationSpending = "SE.XPD.TOTL.GD.ZS"
    case primaryEnrollment = "SE.PRM.ENRR"
    case secondaryEnrollment = "SE.SEC.ENRR"
    case tertiaryEnrollment = "SE.TER.ENRR"

    // Health
    case infantMortality = "SH.DYN.MORT"
    case healthExpenditure = "SH.XPD.CHEX.GD.ZS"

    // Technology
    case internetUsers = "IT.NET.USER.ZS"
    case mobileSubscriptions = "IT.CEL.SETS.P2"
    case electricityAccess = "EG.ELC.ACCS.ZS"
    case co2Emissions = "EN.ATM.CO2E.PC"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gdp: "GDP"
        case .gdpPerCapita: "GDP per Capita"
        case .gdpGrowth: "GDP Growth"
        case .inflation: "Inflation Rate"
        case .unemployment: "Unemployment"
        case .trade: "Trade (% of GDP)"
        case .population: "Population"
        case .lifeExpectancy: "Life Expectancy"
        case .fertilityRate: "Fertility Rate"
        case .urbanPopulation: "Urban Population"
        case .populationGrowth: "Population Growth"
        case .birthRate: "Birth Rate"
        case .deathRate: "Death Rate"
        case .literacyRate: "Literacy Rate"
        case .educationSpending: "Education Spending"
        case .primaryEnrollment: "Primary Enrollment"
        case .secondaryEnrollment: "Secondary Enrollment"
        case .tertiaryEnrollment: "Tertiary Enrollment"
        case .infantMortality: "Infant Mortality"
        case .healthExpenditure: "Health Expenditure"
        case .internetUsers: "Internet Users"
        case .mobileSubscriptions: "Mobile Subscriptions"
        case .electricityAccess: "Electricity Access"
        case .co2Emissions: "CO₂ Emissions"
        }
    }

    var unit: String {
        switch self {
        case .gdp: "USD"
        case .gdpPerCapita: "USD"
        case .gdpGrowth: "%"
        case .inflation: "%"
        case .unemployment: "%"
        case .trade: "% of GDP"
        case .population: "people"
        case .lifeExpectancy: "years"
        case .fertilityRate: "births/woman"
        case .urbanPopulation: "%"
        case .populationGrowth: "%"
        case .birthRate: "per 1,000"
        case .deathRate: "per 1,000"
        case .literacyRate: "%"
        case .educationSpending: "% of GDP"
        case .primaryEnrollment: "%"
        case .secondaryEnrollment: "%"
        case .tertiaryEnrollment: "%"
        case .infantMortality: "per 1,000 live births"
        case .healthExpenditure: "% of GDP"
        case .internetUsers: "%"
        case .mobileSubscriptions: "per 100 people"
        case .electricityAccess: "%"
        case .co2Emissions: "t/capita"
        }
    }

    var icon: String {
        switch self {
        case .gdp: "chart.bar.fill"
        case .gdpPerCapita: "dollarsign.circle"
        case .gdpGrowth: "chart.line.uptrend.xyaxis"
        case .inflation: "arrow.up.forward"
        case .unemployment: "briefcase"
        case .trade: "arrow.left.arrow.right"
        case .population: "person.3"
        case .lifeExpectancy: "heart.fill"
        case .fertilityRate: "figure.and.child.holdinghands"
        case .urbanPopulation: "building.2"
        case .populationGrowth: "person.badge.plus"
        case .birthRate: "figure.2.and.child.holdinghands"
        case .deathRate: "minus.circle"
        case .literacyRate: "book"
        case .educationSpending: "graduationcap"
        case .primaryEnrollment: "pencil"
        case .secondaryEnrollment: "pencil.and.ruler"
        case .tertiaryEnrollment: "graduationcap.fill"
        case .infantMortality: "cross.case"
        case .healthExpenditure: "cross.fill"
        case .internetUsers: "wifi"
        case .mobileSubscriptions: "iphone"
        case .electricityAccess: "bolt.fill"
        case .co2Emissions: "smoke"
        }
    }

    /// Whether a higher value is generally better for this indicator
    var higherIsBetter: Bool {
        switch self {
        case .gdp, .gdpPerCapita, .gdpGrowth, .trade, .lifeExpectancy, .urbanPopulation,
             .literacyRate, .educationSpending, .primaryEnrollment, .secondaryEnrollment,
             .tertiaryEnrollment, .healthExpenditure, .internetUsers, .mobileSubscriptions,
             .electricityAccess:
            true
        case .inflation, .unemployment, .fertilityRate, .populationGrowth, .birthRate,
             .deathRate, .infantMortality, .co2Emissions, .population:
            false
        }
    }

    // swiftlint:disable:next function_body_length
    func format(_ value: Double) -> String {
        switch self {
        case .gdp:
            if value >= 1e12 { return String(format: "$%.2fT", value / 1e12) }
            if value >= 1e9 { return String(format: "$%.1fB", value / 1e9) }
            if value >= 1e6 { return String(format: "$%.1fM", value / 1e6) }
            return String(format: "$%.0f", value)
        case .gdpPerCapita:
            if value >= 1000 { return String(format: "$%.0fK", value / 1000) }
            return String(format: "$%.0f", value)
        case .population:
            if value >= 1e9 { return String(format: "%.2fB", value / 1e9) }
            if value >= 1e6 { return String(format: "%.1fM", value / 1e6) }
            if value >= 1e3 { return String(format: "%.0fK", value / 1e3) }
            return String(format: "%.0f", value)
        case .lifeExpectancy:
            return String(format: "%.1f yrs", value)
        case .fertilityRate:
            return String(format: "%.2f", value)
        case .infantMortality:
            return String(format: "%.1f‰", value)
        case .mobileSubscriptions:
            return String(format: "%.0f/100", value)
        case .co2Emissions:
            return String(format: "%.2f t", value)
        default:
            return String(format: "%.1f%%", value)
        }
    }

    func formatAxisValue(_ value: Double) -> String {
        switch self {
        case .gdp:
            if value >= 1e12 { return "\(Int(value / 1e12))T" }
            if value >= 1e9 { return "\(Int(value / 1e9))B" }
            if value >= 1e6 { return "\(Int(value / 1e6))M" }
            return "\(Int(value))"
        case .gdpPerCapita:
            if value >= 1000 { return "$\(Int(value / 1000))K" }
            return "$\(Int(value))"
        case .population:
            if value >= 1e9 { return "\(Int(value / 1e9))B" }
            if value >= 1e6 { return "\(Int(value / 1e6))M" }
            if value >= 1e3 { return "\(Int(value / 1e3))K" }
            return "\(Int(value))"
        case .co2Emissions, .fertilityRate:
            return String(format: "%.1f", value)
        case .infantMortality, .mobileSubscriptions:
            return String(format: "%.0f", value)
        default:
            return String(format: "%.0f%%", value)
        }
    }
}

// MARK: - WorldBankService

@Observable
final class WorldBankService {
    struct DataPoint: Identifiable, Codable, Hashable {
        let year: Int
        let value: Double

        var id: Int { year }
    }

    private struct CachedEntry: Codable {
        let data: [DataPoint]
        let fetchedAt: Date
    }

    enum LoadState {
        case loading
        case loaded([DataPoint])
        case failed
    }

    private(set) var loadStates: [String: LoadState] = [:]
    private var memoryCache: [String: CachedEntry] = [:]
    private let cacheDirectory: URL
    private let cacheExpiry: TimeInterval = 30 * 24 * 3600 // 30 days

    init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let directory = caches.appendingPathComponent("WorldBank", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        cacheDirectory = directory
    }

    func prefetchAll(for countryCode: String) async {
        await withTaskGroup(of: Void.self) { group in
            for indicator in StatIndicator.allCases {
                group.addTask { [self] in
                    await self.fetch(indicator, for: countryCode)
                }
            }
        }
    }

    func fetch(_ indicator: StatIndicator, for countryCode: String) async {
        let key = cacheKey(indicator, countryCode: countryCode)
        guard loadStates[key] == nil else { return }

        // Check memory cache
        if let cached = memoryCache[key], !isStale(cached.fetchedAt) {
            loadStates[key] = .loaded(cached.data)
            return
        }

        loadStates[key] = .loading

        // Check disk cache
        if let diskEntry = readDiskCache(key: key), !isStale(diskEntry.fetchedAt) {
            memoryCache[key] = diskEntry
            loadStates[key] = .loaded(diskEntry.data)
            return
        }

        // Network fetch
        let urlString = "https://api.worldbank.org/v2/country/\(countryCode.lowercased())/indicator/\(indicator.rawValue)?format=json&date=1960:2023&per_page=100"
        guard let url = URL(string: urlString) else {
            loadStates[key] = .failed
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let points = try parseResponse(data)
            let entry = CachedEntry(data: points, fetchedAt: Date())
            memoryCache[key] = entry
            writeDiskCache(entry, key: key)
            loadStates[key] = .loaded(points)
        } catch {
            // Fall back to stale disk cache if available
            if let diskEntry = readDiskCache(key: key) {
                memoryCache[key] = diskEntry
                loadStates[key] = .loaded(diskEntry.data)
            } else {
                loadStates[key] = .failed
            }
        }
    }

    func state(for indicator: StatIndicator, countryCode: String) -> LoadState? {
        loadStates[cacheKey(indicator, countryCode: countryCode)]
    }

    func cacheAge(for indicator: StatIndicator, countryCode: String) -> Date? {
        memoryCache[cacheKey(indicator, countryCode: countryCode)]?.fetchedAt
    }
}

// MARK: - Helpers

private extension WorldBankService {
    func cacheKey(_ indicator: StatIndicator, countryCode: String) -> String {
        "\(countryCode)_\(indicator.rawValue)"
    }

    func isStale(_ date: Date) -> Bool {
        Date().timeIntervalSince(date) > cacheExpiry
    }

    func readDiskCache(key: String) -> CachedEntry? {
        let url = cacheDirectory.appendingPathComponent("\(key).json")
        guard let data = try? Data(contentsOf: url),
              let entry = try? JSONDecoder().decode(CachedEntry.self, from: data) else { return nil }
        return entry
    }

    func writeDiskCache(_ entry: CachedEntry, key: String) {
        let url = cacheDirectory.appendingPathComponent("\(key).json")
        guard let data = try? JSONEncoder().encode(entry) else { return }
        try? data.write(to: url)
    }

    func parseResponse(_ data: Data) throws -> [DataPoint] {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [[Any]],
              json.count >= 2,
              let records = json[1] as? [[String: Any]] else { return [] }

        return records.compactMap { record -> DataPoint? in
            guard let dateString = record["date"] as? String,
                  let year = Int(dateString) else { return nil }
            let rawValue = record["value"]
            let doubleValue: Double?
            if let value = rawValue as? Double {
                doubleValue = value
            } else if let valueString = rawValue as? String {
                doubleValue = Double(valueString)
            } else {
                doubleValue = nil
            }
            guard let value = doubleValue else { return nil }
            return DataPoint(year: year, value: value)
        }
        .sorted { $0.year < $1.year }
    }
}

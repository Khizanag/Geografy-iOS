import Foundation
import Geografy_Core_Common
import Observation

// MARK: - Stat Category
public enum StatCategory: String, CaseIterable, Identifiable {
    case economy
    case demographics
    case education
    case health
    case technology

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .economy: "Economy"
        case .demographics: "Demographics"
        case .education: "Education"
        case .health: "Health"
        case .technology: "Technology"
        }
    }

    public var icon: String {
        switch self {
        case .economy: "chart.line.uptrend.xyaxis"
        case .demographics: "person.3"
        case .education: "book"
        case .health: "heart.text.clipboard"
        case .technology: "wifi"
        }
    }

    public var indicators: [StatIndicator] {
        switch self {
        case .economy: [.gdp, .gdpPerCapita, .gdpGrowth, .inflation, .unemployment, .trade]
        case .demographics: [
            .population, .lifeExpectancy, .fertilityRate, .urbanPopulation,
            .populationGrowth, .birthRate, .deathRate,
        ]
        case .education: [
            .literacyRate, .educationSpending, .primaryEnrollment,
            .secondaryEnrollment, .tertiaryEnrollment,
        ]
        case .health: [.infantMortality, .healthExpenditure]
        case .technology: [.internetUsers, .mobileSubscriptions, .electricityAccess, .co2Emissions]
        }
    }
}

// MARK: - Stat Indicator
public enum StatIndicator: String, CaseIterable, Identifiable, Sendable {
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

    public var id: String { rawValue }

    public var title: String {
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

    public var unit: String {
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

    public var icon: String {
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
    public var higherIsBetter: Bool {
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

    public func format(_ value: Double) -> String {
        switch self {
        case .gdp: formatLargeCurrency(value)
        case .gdpPerCapita: formatSmallCurrency(value)
        case .population: formatPopulationValue(value)
        case .lifeExpectancy: String(format: "%.1f yrs", value)
        case .fertilityRate: String(format: "%.2f", value)
        case .infantMortality: String(format: "%.1f‰", value)
        case .mobileSubscriptions: String(format: "%.0f/100", value)
        case .co2Emissions: String(format: "%.2f t", value)
        default: String(format: "%.1f%%", value)
        }
    }

    private func formatLargeCurrency(_ value: Double) -> String {
        if value >= 1e12 { return String(format: "$%.2fT", value / 1e12) }
        if value >= 1e9 { return String(format: "$%.1fB", value / 1e9) }
        if value >= 1e6 { return String(format: "$%.1fM", value / 1e6) }
        return String(format: "$%.0f", value)
    }

    private func formatSmallCurrency(_ value: Double) -> String {
        if value >= 1_000 { return String(format: "$%.0fK", value / 1_000) }
        return String(format: "$%.0f", value)
    }

    private func formatPopulationValue(_ value: Double) -> String {
        if value >= 1e9 { return String(format: "%.2fB", value / 1e9) }
        if value >= 1e6 { return String(format: "%.1fM", value / 1e6) }
        if value >= 1e3 { return String(format: "%.0fK", value / 1e3) }
        return String(format: "%.0f", value)
    }

    public func formatAxisValue(_ value: Double) -> String {
        switch self {
        case .gdp:
            if value >= 1e12 { return "\(Int(value / 1e12))T" }
            if value >= 1e9 { return "\(Int(value / 1e9))B" }
            if value >= 1e6 { return "\(Int(value / 1e6))M" }
            return "\(Int(value))"
        case .gdpPerCapita:
            if value >= 1_000 { return "$\(Int(value / 1_000))K" }
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
@MainActor
public final class WorldBankService {
    public struct DataPoint: Identifiable, Codable, Hashable, Sendable {
        public let year: Int
        public let value: Double

        public var id: Int { year }

        public init(year: Int, value: Double) {
            self.year = year
            self.value = value
        }
    }

    fileprivate struct CachedEntry: Codable, Sendable {
        let data: [DataPoint]
        let fetchedAt: Date
    }

    public enum LoadState {
        case loading
        case loaded([DataPoint])
        case failed
    }

    public private(set) var loadStates: [String: LoadState] = [:]
    // Every write lands in the same turn as a loadStates write, so observing it would only add redraws.
    @ObservationIgnored private var memoryCache: [String: CachedEntry] = [:]
    private let cacheDirectory: URL
    private let cacheExpiry: TimeInterval = 30 * 24 * 3_600 // 30 days

    public init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let directory = caches.appendingPathComponent("WorldBank", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        cacheDirectory = directory
    }

    public func fetch(_ indicators: [StatIndicator], for countryCode: String) async {
        let missingKeys = markPending(indicators, countryCode: countryCode)
        guard !missingKeys.isEmpty else { return }

        let diskEntries = await Self.readDiskCache(keys: missingKeys, in: cacheDirectory)
        let networkKeys = applyFreshDiskEntries(diskEntries, keys: missingKeys)
        guard !networkKeys.isEmpty else { return }

        let directory = cacheDirectory
        let requests = indicators.map { indicator in
            (key: cacheKey(indicator, countryCode: countryCode), url: requestURL(indicator, countryCode: countryCode))
        }
        await withTaskGroup(of: (String, CachedEntry?).self) { group in
            for request in requests where networkKeys.contains(request.key) {
                group.addTask {
                    (request.key, await Self.download(from: request.url, key: request.key, cacheDirectory: directory))
                }
            }
            for await (key, entry) in group {
                applyNetworkResult(entry, fallback: diskEntries[key], key: key)
            }
        }
    }

    public func fetch(_ indicator: StatIndicator, for countryCode: String) async {
        await fetch([indicator], for: countryCode)
    }

    public func state(for indicator: StatIndicator, countryCode: String) -> LoadState? {
        loadStates[cacheKey(indicator, countryCode: countryCode)]
    }

    public func cacheAge(for indicator: StatIndicator, countryCode: String) -> Date? {
        memoryCache[cacheKey(indicator, countryCode: countryCode)]?.fetchedAt
    }
}

// MARK: - State Updates
private extension WorldBankService {
    func markPending(_ indicators: [StatIndicator], countryCode: String) -> [String] {
        var states = loadStates
        var missingKeys: [String] = []
        var hasChanges = false
        for indicator in indicators {
            let key = cacheKey(indicator, countryCode: countryCode)
            switch states[key] {
            case .loading: continue
            case .loaded(let points) where !points.isEmpty: continue
            default: break
            }
            hasChanges = true
            if let cached = memoryCache[key], !isStale(cached.fetchedAt), !cached.data.isEmpty {
                states[key] = .loaded(cached.data)
            } else {
                states[key] = .loading
                missingKeys.append(key)
            }
        }
        if hasChanges {
            loadStates = states
        }
        return missingKeys
    }

    func applyFreshDiskEntries(_ entries: [String: CachedEntry], keys: [String]) -> [String] {
        var states = loadStates
        var networkKeys: [String] = []
        for key in keys {
            if let entry = entries[key], !isStale(entry.fetchedAt), !entry.data.isEmpty {
                memoryCache[key] = entry
                states[key] = .loaded(entry.data)
            } else {
                networkKeys.append(key)
            }
        }
        if networkKeys.count != keys.count {
            loadStates = states
        }
        return networkKeys
    }

    func applyNetworkResult(_ entry: CachedEntry?, fallback: CachedEntry?, key: String) {
        guard let resolved = entry ?? fallback else {
            loadStates[key] = .failed
            return
        }
        memoryCache[key] = resolved
        loadStates[key] = .loaded(resolved.data)
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

    func requestURL(_ indicator: StatIndicator, countryCode: String) -> URL? {
        URL(
            string: "https://api.worldbank.org/v2/country/\(countryCode.lowercased())/indicator/\(indicator.rawValue)"
                + "?format=json&date=1960:2023&per_page=100"
        )
    }
}

// MARK: - Loading
private extension WorldBankService {
    @concurrent
    nonisolated static func readDiskCache(keys: [String], in directory: URL) async -> [String: CachedEntry] {
        let decoder = JSONDecoder()
        var entries: [String: CachedEntry] = [:]
        for key in keys {
            let url = directory.appendingPathComponent("\(key).json")
            guard let data = try? Data(contentsOf: url),
                  let entry = try? decoder.decode(CachedEntry.self, from: data) else { continue }
            entries[key] = entry
        }
        return entries
    }

    @concurrent
    nonisolated static func download(from url: URL?, key: String, cacheDirectory: URL) async -> CachedEntry? {
        guard let url,
              let (data, _) = try? await URLSession.shared.data(from: url),
              let points = try? parseResponse(data) else { return nil }
        let entry = CachedEntry(data: points, fetchedAt: Date())
        if !points.isEmpty, let encoded = try? JSONEncoder().encode(entry) {
            try? encoded.write(to: cacheDirectory.appendingPathComponent("\(key).json"))
        }
        return entry
    }

    nonisolated static func parseResponse(_ data: Data) throws -> [DataPoint] {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [Any],
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
        .sorted(by: \.year)
    }
}

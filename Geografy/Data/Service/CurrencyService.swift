import Foundation
import Geografy_Core_Common
import Observation

@Observable
@MainActor
final class CurrencyService {
    private(set) var rates: [String: Double] = [:]
    private(set) var lastUpdated: Date?
    private(set) var isLoading = false
    private(set) var fetchError: String?
    private(set) var baseCurrency = "USD"

    private var memoryCache: [String: CachedRates] = [:]
    private let cacheDirectory: URL
    private let cacheExpiry: TimeInterval = 24 * 3600

    struct CachedRates: Codable {
        let baseCurrency: String
        let rates: [String: Double]
        let fetchedAt: Date
    }

    private struct ExchangeResponse: Codable {
        let result: String
        let baseCode: String
        let rates: [String: Double]

        enum CodingKeys: String, CodingKey {
            case result
            case baseCode = "base_code"
            case rates
        }
    }

    init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDirectory = caches.appendingPathComponent("CurrencyRates", isDirectory: true)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    func fetchRates(for base: String) async {
        if let cached = readCache(for: base), !isStale(cached.fetchedAt) {
            applyCache(cached)
            return
        }

        isLoading = true
        fetchError = nil
        defer { isLoading = false }

        guard let url = URL(string: "https://open.er-api.com/v6/latest/\(base)") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(ExchangeResponse.self, from: data)
            guard response.result == "success" else {
                fetchError = "Exchange rate service unavailable"
                fallbackToStaleCache(for: base)
                return
            }
            let cached = CachedRates(baseCurrency: base, rates: response.rates, fetchedAt: Date())
            writeCache(cached, for: base)
            applyCache(cached)
        } catch {
            fetchError = "Network unavailable — showing cached rates"
            fallbackToStaleCache(for: base)
        }
    }

    func convert(amount: Double, from fromCode: String, to toCode: String) -> Double? {
        guard !rates.isEmpty else { return nil }
        if baseCurrency == fromCode {
            guard let toRate = rates[toCode] else { return nil }
            return amount * toRate
        }
        guard let fromRate = rates[fromCode], let toRate = rates[toCode], fromRate != 0 else { return nil }
        return amount / fromRate * toRate
    }

    func cacheAge(for base: String) -> Date? {
        readCache(for: base)?.fetchedAt
    }
}

// MARK: - Cache
private extension CurrencyService {
    func cacheURL(for base: String) -> URL {
        cacheDirectory.appendingPathComponent("\(base).json")
    }

    func readCache(for base: String) -> CachedRates? {
        if let memory = memoryCache[base] { return memory }
        guard let data = try? Data(contentsOf: cacheURL(for: base)),
              let cached = try? JSONDecoder().decode(CachedRates.self, from: data)
        else { return nil }
        memoryCache[base] = cached
        return cached
    }

    func writeCache(_ cached: CachedRates, for base: String) {
        memoryCache[base] = cached
        if let data = try? JSONEncoder().encode(cached) {
            try? data.write(to: cacheURL(for: base))
        }
    }

    func isStale(_ date: Date) -> Bool {
        Date().timeIntervalSince(date) > cacheExpiry
    }

    func applyCache(_ cached: CachedRates) {
        rates = cached.rates
        lastUpdated = cached.fetchedAt
        baseCurrency = cached.baseCurrency
    }

    func fallbackToStaleCache(for base: String) {
        if let stale = readCache(for: base) {
            applyCache(stale)
        }
    }
}

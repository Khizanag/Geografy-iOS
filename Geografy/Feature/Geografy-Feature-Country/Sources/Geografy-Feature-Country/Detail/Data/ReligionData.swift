import Foundation
import Geografy_Core_Common

/// Religions per country with their share of the population, keyed by country code, from `religions.json`.
public enum ReligionData: Sendable {
    public static let data = BundledJSON.decode([String: [PercentageItem]].self, named: "religions", in: .module) ?? [:]
}

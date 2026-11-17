import Foundation
import Geografy_Core_Common

/// Ethnic groups per country with their share of the population, keyed by country code, from `ethnicities.json`.
public enum EthnicityData: Sendable {
    public static let data = BundledJSON.decode(
        [String: [PercentageItem]].self,
        named: "ethnicities",
        in: .module
    ) ?? [:]
}

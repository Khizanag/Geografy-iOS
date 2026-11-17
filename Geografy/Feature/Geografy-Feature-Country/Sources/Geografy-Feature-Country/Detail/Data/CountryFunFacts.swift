import Foundation
import Geografy_Core_Common

/// A few surprising facts per country, keyed by country code, from `country_fun_facts.json`.
public enum CountryFunFacts: Sendable {
    public static let data = BundledJSON.decode([String: [String]].self, named: "country_fun_facts", in: .module) ?? [:]
}

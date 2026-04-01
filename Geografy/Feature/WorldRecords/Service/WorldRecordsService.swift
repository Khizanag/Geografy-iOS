import Foundation
import Geografy_Core_Common

struct WorldRecordsService {
    func computeRecords(from countries: [Country]) -> [WorldRecord] {
        var records: [WorldRecord] = []

        records += areaRecords(from: countries)
        records += populationRecords(from: countries)
        records += populationDensityRecords(from: countries)
        records += neighborRecords(from: countries)
        records += nameLengthRecords(from: countries)
        records += languageRecords(from: countries)
        records += gdpPerCapitaRecords(from: countries)

        return records
    }
}

// MARK: - Helpers
private extension WorldRecordsService {
    func areaRecords(from countries: [Country]) -> [WorldRecord] {
        let sorted = countries.sorted { $0.area > $1.area }
        var result: [WorldRecord] = []

        if let largest = sorted.first {
            let formattedArea = NumberFormatter.localizedString(
                from: NSNumber(value: largest.area),
                number: .decimal
            )
            result.append(
                WorldRecord(
                    category: .area,
                    title: "Largest Country",
                    countryCode: largest.code,
                    countryName: largest.name,
                    value: "\(formattedArea) km²",
                    unit: "km²",
                    description: "\(largest.name) is the largest country in the world by land area."
                )
            )
        }

        if let smallest = sorted.last {
            let formattedArea = String(format: "%.2f", smallest.area)
            result.append(
                WorldRecord(
                    category: .area,
                    title: "Smallest Country",
                    countryCode: smallest.code,
                    countryName: smallest.name,
                    value: "\(formattedArea) km²",
                    unit: "km²",
                    description: "\(smallest.name) is the smallest country in the world by land area."
                )
            )
        }

        return result
    }

    func populationRecords(from countries: [Country]) -> [WorldRecord] {
        let sorted = countries.sorted { $0.population > $1.population }
        var result: [WorldRecord] = []

        if let mostPopulous = sorted.first {
            let formatted = NumberFormatter.localizedString(
                from: NSNumber(value: mostPopulous.population),
                number: .decimal
            )
            result.append(
                WorldRecord(
                    category: .population,
                    title: "Most Populous",
                    countryCode: mostPopulous.code,
                    countryName: mostPopulous.name,
                    value: formatted,
                    unit: "people",
                    description: "\(mostPopulous.name) has the largest population in the world."
                )
            )
        }

        if let leastPopulous = sorted.last {
            let formatted = NumberFormatter.localizedString(
                from: NSNumber(value: leastPopulous.population),
                number: .decimal
            )
            result.append(
                WorldRecord(
                    category: .population,
                    title: "Least Populous",
                    countryCode: leastPopulous.code,
                    countryName: leastPopulous.name,
                    value: formatted,
                    unit: "people",
                    description: "\(leastPopulous.name) has the smallest population in the world."
                )
            )
        }

        return result
    }

    func populationDensityRecords(from countries: [Country]) -> [WorldRecord] {
        let filtered = countries.filter { $0.populationDensity > 0 }
        let sorted = filtered.sorted { $0.populationDensity > $1.populationDensity }
        var result: [WorldRecord] = []

        if let densest = sorted.first {
            let formatted = String(format: "%.1f", densest.populationDensity)
            result.append(
                WorldRecord(
                    category: .populationDensity,
                    title: "Highest Density",
                    countryCode: densest.code,
                    countryName: densest.name,
                    value: "\(formatted)/km²",
                    unit: "people/km²",
                    description: "\(densest.name) has the highest population density in the world."
                )
            )
        }

        if let leastDense = sorted.last {
            let formatted = String(format: "%.2f", leastDense.populationDensity)
            result.append(
                WorldRecord(
                    category: .populationDensity,
                    title: "Lowest Density",
                    countryCode: leastDense.code,
                    countryName: leastDense.name,
                    value: "\(formatted)/km²",
                    unit: "people/km²",
                    description: "\(leastDense.name) has the lowest population density in the world."
                )
            )
        }

        return result
    }

    func neighborRecords(from countries: [Country]) -> [WorldRecord] {
        var result: [WorldRecord] = []

        let withNeighborCount = countries.map { country in
            (country: country, count: CountryNeighbors.data[country.code]?.count ?? 0)
        }

        if let mostNeighbors = withNeighborCount.max(by: { $0.count < $1.count }) {
            result.append(
                WorldRecord(
                    category: .neighbors,
                    title: "Most Neighbors",
                    countryCode: mostNeighbors.country.code,
                    countryName: mostNeighbors.country.name,
                    value: "\(mostNeighbors.count) borders",
                    unit: "borders",
                    description: "\(mostNeighbors.country.name) shares borders with \(mostNeighbors.count) countries."
                )
            )
        }

        let islandNations = countries.filter {
            (CountryNeighbors.data[$0.code]?.isEmpty ?? true)
                && !CountryNeighbors.data.keys.contains($0.code)
        }
        let islandCount = islandNations.count

        if let islandExample = islandNations.sorted(by: { $0.population > $1.population }).first {
            result.append(
                WorldRecord(
                    category: .neighbors,
                    title: "Island Nations",
                    countryCode: islandExample.code,
                    countryName: islandExample.name,
                    value: "\(islandCount) nations",
                    unit: "island nations",
                    description: "There are \(islandCount) island nations with no land borders."
                )
            )
        }

        return result
    }

    func nameLengthRecords(from countries: [Country]) -> [WorldRecord] {
        let sorted = countries.sorted { $0.name.count > $1.name.count }
        var result: [WorldRecord] = []

        if let longest = sorted.first {
            result.append(
                WorldRecord(
                    category: .nameLength,
                    title: "Longest Name",
                    countryCode: longest.code,
                    countryName: longest.name,
                    value: "\(longest.name.count) letters",
                    unit: "letters",
                    description: "\(longest.name) has the longest country name with \(longest.name.count) characters."
                )
            )
        }

        if let shortest = sorted.last {
            result.append(
                WorldRecord(
                    category: .nameLength,
                    title: "Shortest Name",
                    countryCode: shortest.code,
                    countryName: shortest.name,
                    value: "\(shortest.name.count) letters",
                    unit: "letters",
                    description: "\(shortest.name) has the shortest country name with \(shortest.name.count) characters."
                )
            )
        }

        return result
    }

    func languageRecords(from countries: [Country]) -> [WorldRecord] {
        let sorted = countries.sorted { $0.languages.count > $1.languages.count }
        var result: [WorldRecord] = []

        if let mostLanguages = sorted.first {
            result.append(
                WorldRecord(
                    category: .languages,
                    title: "Most Languages",
                    countryCode: mostLanguages.code,
                    countryName: mostLanguages.name,
                    value: "\(mostLanguages.languages.count) languages",
                    unit: "languages",
                    description: "\(mostLanguages.name) has \(mostLanguages.languages.count) official languages."
                )
            )
        }

        return result
    }

    func gdpPerCapitaRecords(from countries: [Country]) -> [WorldRecord] {
        let withGDP = countries.compactMap { country -> (country: Country, gdpPerCapita: Double)? in
            guard let value = country.gdpPerCapita, value > 0 else { return nil }
            return (country: country, gdpPerCapita: value)
        }
        let sorted = withGDP.sorted { $0.gdpPerCapita > $1.gdpPerCapita }
        var result: [WorldRecord] = []

        if let richest = sorted.first {
            let formatted = NumberFormatter.localizedString(
                from: NSNumber(value: richest.gdpPerCapita),
                number: .decimal
            )
            result.append(
                WorldRecord(
                    category: .gdpPerCapita,
                    title: "Highest GDP per Capita",
                    countryCode: richest.country.code,
                    countryName: richest.country.name,
                    value: "$\(formatted)",
                    unit: "USD",
                    description: "\(richest.country.name) has the highest GDP per capita."
                )
            )
        }

        if let poorest = sorted.last {
            let formatted = NumberFormatter.localizedString(
                from: NSNumber(value: poorest.gdpPerCapita),
                number: .decimal
            )
            result.append(
                WorldRecord(
                    category: .gdpPerCapita,
                    title: "Lowest GDP per Capita",
                    countryCode: poorest.country.code,
                    countryName: poorest.country.name,
                    value: "$\(formatted)",
                    unit: "USD",
                    description: "\(poorest.country.name) has the lowest GDP per capita."
                )
            )
        }

        return result
    }
}

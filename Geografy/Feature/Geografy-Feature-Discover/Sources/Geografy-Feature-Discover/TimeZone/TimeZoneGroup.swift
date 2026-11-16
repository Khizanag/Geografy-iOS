/// The countries sharing one UTC offset, for the By Zone list.
struct TimeZoneGroup {
    let offset: Double
    let countries: [CountryWithZone]

    /// Groups by current offset, west to east, with each group's countries by name.
    static func groups(from countries: [CountryWithZone]) -> [TimeZoneGroup] {
        Dictionary(grouping: countries, by: \.utcOffsetHours)
            .map { offset, members in
                TimeZoneGroup(offset: offset, countries: members.sorted { $0.country.name < $1.country.name })
            }
            .sorted { $0.offset < $1.offset }
    }
}

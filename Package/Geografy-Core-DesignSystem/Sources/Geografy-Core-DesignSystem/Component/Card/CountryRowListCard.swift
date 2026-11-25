import Geografy_Core_Common
import SwiftUI

/// Countries as one card of rows, each as every country list in the app draws it: a tap opens the country, a long
/// press previews it with Open, Copy, and Share, and, when the list can lose a country, a swipe or Remove takes it
/// out (article 12).
public struct CountryRowListCard: View {
    // MARK: - Properties
    private let countries: [Country]
    private let open: (Country) -> Void
    private let remove: ((Country) -> Void)?

    // MARK: - Init
    /// - Parameter remove: Takes a country out of the list; nil for a list it can't leave.
    public init(
        _ countries: [Country],
        open: @escaping (Country) -> Void,
        remove: ((Country) -> Void)? = nil
    ) {
        self.countries = countries
        self.open = open
        self.remove = remove
    }

    // MARK: - Body
    public var body: some View {
        RowListCard(
            countries,
            dividerInset: RowListCardLayout.dividerInset(after: RowListCardLayout.flagWidth),
            menu: .countries(open: open, remove: remove)
        ) { country in
            Button {
                open(country)
            } label: {
                CountryListRow(country: country) { RowChevron() }
                    .rowListCardRow()
            }
            .buttonStyle(PressButtonStyle())
            .accessibilityElement(children: .combine)
            .accessibilityHint(Text("Opens the country", bundle: .module))
        }
    }
}

import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct CompareScreen: View {
    // MARK: - Properties
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    #endif
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var leftCountry: Country?
    @State private var rightCountry: Country?
    @State private var pickingSide: CompareSide?
    @State private var recentPairs: [ComparisonPair] = []

    private let preselectedCountry: Country?

    private static let recentLimit = 5
    private static let recentStorageKey = "compare_recent_pairs"

    // MARK: - Init
    public init(preselectedCountry: Country? = nil) {
        self.preselectedCountry = preselectedCountry
    }

    // MARK: - Body
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                matchupHeader
                content
                if !recentPairs.isEmpty {
                    recentSection
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.xs)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
        .screenBackground()
        .navigationTitle("Compare")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: setUp)
        .sheet(item: $pickingSide) { side in
            CoordinatedNavigationStack(showCloseButton: true) {
                picker(for: side)
            }
        }
    }
}

// MARK: - Matchup
private extension CompareScreen {
    var isStacked: Bool { dynamicTypeSize.isAccessibilitySize }

    var matchupHeader: some View {
        let layout = isStacked
            ? AnyLayout(VStackLayout(spacing: DesignSystem.Spacing.xs))
            : AnyLayout(HStackLayout(spacing: DesignSystem.Spacing.xs))
        return layout {
            slot(for: .left)
            centerControl
            slot(for: .right)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    func slot(for side: CompareSide) -> some View {
        CompareCountrySlot(
            country: country(on: side),
            side: side,
            onPick: { pickingSide = side },
            onClear: { setCountry(nil, on: side) }
        )
    }

    /// "VS" until both are picked, then a glass button that swaps them.
    @ViewBuilder
    var centerControl: some View {
        if leftCountry != nil, rightCountry != nil {
            Button(action: swapCountries) {
                Image(systemName: isStacked ? "arrow.up.arrow.down" : "arrow.left.arrow.right")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .frame(width: DesignSystem.Size.xl, height: DesignSystem.Size.xl)
                    .glassEffect(.regular.interactive(), in: .circle)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Swap countries")
        } else {
            Text("VS")
                .font(DesignSystem.Font.caption)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .frame(width: DesignSystem.Size.xl, height: DesignSystem.Size.xl)
                .glassEffect(.regular, in: .circle)
                .accessibilityHidden(true)
        }
    }
}

// MARK: - Content
private extension CompareScreen {
    @ViewBuilder
    var content: some View {
        if let leftCountry, let rightCountry {
            CompareMetricsView(left: leftCountry, right: rightCountry)
        } else {
            CompareStartView(
                leftCountry: leftCountry,
                rightCountry: rightCountry,
                countries: countryDataService.countries,
                onChoose: { country, side in setCountry(country, on: side) },
                onChoosePair: open,
                onShuffle: shuffle
            )
        }
    }

    var recentSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                SectionHeaderView(title: "Recent")
                Spacer(minLength: DesignSystem.Spacing.sm)
                Button("Clear", action: clearRecents)
                    .buttonStyle(.glass)
                    .controlSize(.small)
                    .accessibilityLabel("Clear recent comparisons")
            }
            CompareRowList(
                items: Array(recentPairs.prefix(Self.recentLimit)),
                leadingWidth: CompareRowLayout.pairWidth
            ) { pair in
                CompareMatchupRow(pair: pair) {
                    open(pair)
                }
            }
        }
    }

    func picker(for side: CompareSide) -> some View {
        let otherCode = country(on: side == .left ? .right : .left)?.code
        return CountryPicker(
            countries: countryDataService.countries.filter { $0.code != otherCode },
            selectedCode: country(on: side)?.code
        ) { selected in
            setCountry(selected, on: side)
        }
    }
}

// MARK: - Actions
private extension CompareScreen {
    func setUp() {
        loadRecentPairs()
        if let preselectedCountry, leftCountry == nil {
            leftCountry = preselectedCountry
        }
    }

    func country(on side: CompareSide) -> Country? {
        switch side {
        case .left: leftCountry
        case .right: rightCountry
        }
    }

    func setCountry(_ country: Country?, on side: CompareSide) {
        withAnimation(reduceMotion ? nil : .smooth(duration: 0.3)) {
            switch side {
            case .left: leftCountry = country
            case .right: rightCountry = country
            }
        }
        saveIfBothSelected()
    }

    func open(_ pair: ComparisonPair) {
        withAnimation(reduceMotion ? nil : .smooth(duration: 0.3)) {
            leftCountry = countryDataService.country(for: pair.leftCode)
            rightCountry = countryDataService.country(for: pair.rightCode)
        }
        saveIfBothSelected()
    }

    func swapCountries() {
        #if !os(tvOS)
        hapticsService.impact(.light)
        #endif
        withAnimation(reduceMotion ? nil : .smooth(duration: 0.3)) {
            (leftCountry, rightCountry) = (rightCountry, leftCountry)
        }
    }

    /// Fills whichever slots are empty with random countries.
    func shuffle() {
        let pool = countryDataService.countries
        let left = leftCountry ?? pool.filter { $0.code != rightCountry?.code }.randomElement()
        let right = rightCountry ?? pool.filter { $0.code != left?.code }.randomElement()
        withAnimation(reduceMotion ? nil : .smooth(duration: 0.3)) {
            leftCountry = left
            rightCountry = right
        }
        saveIfBothSelected()
    }

    func clearRecents() {
        withAnimation(reduceMotion ? nil : .smooth(duration: 0.3)) {
            recentPairs = []
        }
        saveRecentPairs()
    }
}

// MARK: - Recents
private extension CompareScreen {
    func saveIfBothSelected() {
        guard let leftCountry, let rightCountry else { return }
        let pair = ComparisonPair(left: leftCountry, right: rightCountry)
        recentPairs.removeAll { $0.matches(pair) }
        recentPairs.insert(pair, at: 0)
        recentPairs = Array(recentPairs.prefix(Self.recentLimit))
        saveRecentPairs()
    }

    func saveRecentPairs() {
        guard let data = try? JSONEncoder().encode(recentPairs) else { return }
        UserDefaults.standard.set(data, forKey: UserScope.key(Self.recentStorageKey))
    }

    func loadRecentPairs() {
        guard let data = UserDefaults.standard.data(forKey: UserScope.key(Self.recentStorageKey)),
              let decoded = try? JSONDecoder().decode([ComparisonPair].self, from: data) else {
            return
        }
        recentPairs = decoded
    }
}

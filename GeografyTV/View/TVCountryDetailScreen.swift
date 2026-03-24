import SwiftUI

struct TVCountryDetailScreen: View {
    @Environment(FavoritesService.self) private var favoritesService

    let country: Country

    var body: some View {
        ScrollView {
            VStack(spacing: 60) {
                heroSection

                actionsRow

                factsGrid

                languagesSection


                organizationsSection
            }
            .padding(80)
        }
        .navigationTitle(country.name)
    }
}

// MARK: - Hero

private extension TVCountryDetailScreen {
    var heroSection: some View {
        HStack(spacing: 48) {
            FlagView(countryCode: country.code, height: 160)

            VStack(alignment: .leading, spacing: 16) {
                Text(country.name)
                    .font(.system(size: 52, weight: .bold))
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                Text(country.continent.displayName)
                    .font(.system(size: 28))
                    .foregroundStyle(DesignSystem.Color.textSecondary)

                Text(country.flagEmoji)
                    .font(.system(size: 40))
            }

            Spacer()
        }
    }
}

// MARK: - Actions

private extension TVCountryDetailScreen {
    var actionsRow: some View {
        HStack(spacing: 24) {
            Button {
                favoritesService.toggle(code: country.code)
            } label: {
                Label(
                    favoritesService.isFavorite(code: country.code) ? "Remove Favorite" : "Add to Favorites",
                    systemImage: favoritesService.isFavorite(code: country.code) ? "heart.fill" : "heart"
                )
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(
                    favoritesService.isFavorite(code: country.code)
                        ? DesignSystem.Color.error
                        : DesignSystem.Color.textPrimary
                )
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(DesignSystem.Color.cardBackground, in: RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.card)
        }
    }
}

// MARK: - Facts Grid

private extension TVCountryDetailScreen {
    var factsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 280), spacing: 32)],
            spacing: 32
        ) {
            factCard(icon: "building.columns", title: "Capital", value: country.capital)
            factCard(icon: "person.3", title: "Population", value: country.population.formatted())
            factCard(icon: "map", title: "Area", value: "\(country.area.formatted()) km²")
            factCard(icon: "dollarsign.circle", title: "Currency", value: country.currency.name)
            factCard(icon: "text.bubble", title: "Language", value: country.languages.first?.name ?? "—")

            if let gdpPerCapita = country.gdpPerCapita, gdpPerCapita > 0 {
                factCard(
                    icon: "chart.bar",
                    title: "GDP per Capita",
                    value: "$\(Int(gdpPerCapita).formatted())"
                )
            }
        }
    }

    func factCard(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(width: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18))
                    .foregroundStyle(DesignSystem.Color.textSecondary)

                Text(value)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(24)
        .background(DesignSystem.Color.cardBackground, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Languages

private extension TVCountryDetailScreen {
    @ViewBuilder
    var languagesSection: some View {
        if country.languages.count > 1 {
            VStack(alignment: .leading, spacing: 20) {
                Text("Languages")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                FlowLayout(spacing: 16) {
                    ForEach(country.languages, id: \.name) { language in
                        Text(language.name)
                            .font(.system(size: 20))
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(DesignSystem.Color.cardBackground, in: Capsule())
                    }
                }
            }
        }
    }
}

// MARK: - Organizations

private extension TVCountryDetailScreen {
    @ViewBuilder
    var organizationsSection: some View {
        if !country.organizations.isEmpty {
            VStack(alignment: .leading, spacing: 20) {
                Text("Organizations")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                FlowLayout(spacing: 16) {
                    ForEach(country.organizations, id: \.self) { organization in
                        Text(organization)
                            .font(.system(size: 20))
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(DesignSystem.Color.cardBackground, in: Capsule())
                    }
                }
            }
        }
    }
}

// MARK: - Flow Layout

private struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX)
        }

        return (CGSize(width: maxX, height: currentY + rowHeight), positions)
    }
}

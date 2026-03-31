import SwiftUI
import GeografyDesign

struct FavoriteToggleButton: View {
    @Environment(FavoritesService.self) private var favoritesService
    @Environment(HapticsService.self) private var hapticsService

    let countryCode: String
    var iconSize: CGFloat = 22

    private var isFavorite: Bool {
        favoritesService.isFavorite(code: countryCode)
    }

    var body: some View {
        Button {
            hapticsService.impact(.light)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                favoritesService.toggle(code: countryCode)
            }
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(DesignSystem.Font.system(size: iconSize))
                .foregroundStyle(isFavorite ? DesignSystem.Color.error : DesignSystem.Color.iconPrimary)
                .symbolEffect(.bounce, value: isFavorite)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
    }
}

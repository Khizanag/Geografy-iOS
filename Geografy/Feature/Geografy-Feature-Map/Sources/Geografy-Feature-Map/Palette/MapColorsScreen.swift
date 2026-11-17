import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Map
import SwiftUI

/// Chooses the palette every map colors its countries from, with the world map previewing the choice.
public struct MapColorsScreen: View {
    // MARK: - Properties
    @Environment(HapticsService.self) private var hapticsService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @AppStorage(MapPreferences.paletteKey) private var palette = MapPalette.default.rawValue

    @ScaledMetric(relativeTo: .body) private var previewHeight: CGFloat = 170

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                paletteList
                explanation
            }
            .padding(DesignSystem.Spacing.md)
            .readableContentWidth()
        }
        // A bar this tall gets the hard edge by default; the soft one fades the rows like the navigation bar does.
        .scrollEdgeEffectStyle(.soft, for: .top)
        // Pinned, so every palette can be compared on the map while the rows scroll under its soft edge.
        .safeAreaBar(edge: .top) {
            preview
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.top, DesignSystem.Spacing.xs)
                .padding(.bottom, DesignSystem.Spacing.md)
                .readableContentWidth()
        }
        .screenBackground()
        .navigationTitle("Map Colors")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Subviews
private extension MapColorsScreen {
    var selected: MapPalette { MapPalette(rawValue: palette) ?? .default }

    var preview: some View {
        CardView {
            WorldMapThumbnail()
                .frame(maxWidth: .infinity)
                // Capped, so at the largest text sizes the pinned map still leaves room for the rows.
                .frame(height: min(previewHeight, 220))
                .padding(DesignSystem.Spacing.sm)
                .background(DesignSystem.Color.ocean)
                .id(palette)
                .transition(.opacity)
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: palette)
        .accessibilityLabel(Text("World map in the \(Text(selected.title)) colors"))
    }

    var paletteList: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(MapPalette.allCases) { option in
                paletteRow(option)
            }
        }
    }

    func paletteRow(_ option: MapPalette) -> some View {
        let isSelected = option == selected
        return Button {
            guard !isSelected else { return }
            hapticsService.selection()
            palette = option.rawValue
        } label: {
            HStack(spacing: DesignSystem.Spacing.md) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(option.title)
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text(option.summary)
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    swatches(of: option)
                }
                Spacer(minLength: DesignSystem.Spacing.xs)
                SelectionMark(isSelected: isSelected, color: DesignSystem.Color.accent)
            }
            .padding(DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .selectableTileBackground(isSelected: isSelected, color: DesignSystem.Color.accent)
            .contentShape(.rect(cornerRadius: DesignSystem.CornerRadius.extraLarge))
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    func swatches(of option: MapPalette) -> some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            ForEach(Array(option.colors.enumerated()), id: \.offset) { _, color in
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small / 2)
                    .fill(color)
                    .frame(width: 26, height: 18)
                    .overlay {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small / 2)
                            .strokeBorder(DesignSystem.Color.textPrimary.opacity(DesignSystem.Opacity.faint))
                    }
            }
        }
        .padding(.top, DesignSystem.Spacing.xxs)
        .accessibilityHidden(true)
    }

    var explanation: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Label("How countries get their colors", systemImage: "sparkles")
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(
                """
                Countries that share a border never share a color. Of the colors left, each country takes \
                the one that looks most different from its neighbors, then keeps away from countries just \
                across the sea, so the colors spread evenly over the map.
                """
            )
            .font(DesignSystem.Font.footnote)
            .foregroundStyle(DesignSystem.Color.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, DesignSystem.Spacing.xs)
    }
}

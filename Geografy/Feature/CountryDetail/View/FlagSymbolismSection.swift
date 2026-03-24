import SwiftUI

// MARK: - Flag Symbolism Section

extension CountryDetailScreen {
    var flagSymbolism: FlagSymbolism? {
        FlagSymbolismData.data[country.code]
    }

    @ViewBuilder
    var flagSymbolismSection: some View {
        if let symbolism = flagSymbolism {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                sectionHeader("Flag Symbolism")
                FlagSymbolismCard(symbolism: symbolism)
            }
        }
    }
}

// MARK: - Flag Symbolism Card

private struct FlagSymbolismCard: View {
    let symbolism: FlagSymbolism

    @State private var expanded = false

    var body: some View {
        CardView {
            VStack(spacing: 0) {
                headerRow
                if expanded {
                    colorsSection
                    if !symbolism.emblems.isEmpty {
                        emblemsSection
                    }
                    if let note = symbolism.historicalNote {
                        historicalNoteView(note)
                    }
                }
            }
        }
    }
}

// MARK: - Subviews

private extension FlagSymbolismCard {
    var headerRow: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                expanded.toggle()
            }
        } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(DesignSystem.Color.accent.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: "flag.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(DesignSystem.Color.accent)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Colors & Symbols")
                        .font(DesignSystem.Font.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    if let year = symbolism.adoptedYear {
                        Text("Adopted \(String(year))")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }
                }

                Spacer(minLength: 0)

                colorSwatchRow

                Image(systemName: "chevron.down")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                    .rotationEffect(.degrees(expanded ? 180 : 0))
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: expanded)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressButtonStyle())
    }

    var colorSwatchRow: some View {
        HStack(spacing: 3) {
            ForEach(Array(symbolism.colors.prefix(4).enumerated()), id: \.offset) { _, colorEntry in
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(hex: colorEntry.hex))
                    .frame(width: 14, height: 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
                    )
            }
        }
    }

    var colorsSection: some View {
        VStack(spacing: 0) {
            Divider()
                .padding(.horizontal, DesignSystem.Spacing.md)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                sectionLabel("Colors")
                VStack(spacing: DesignSystem.Spacing.xs) {
                    ForEach(Array(symbolism.colors.enumerated()), id: \.offset) { _, colorEntry in
                        colorRow(colorEntry)
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.sm)
            .padding(.bottom, symbolism.emblems.isEmpty && symbolism.historicalNote == nil ? DesignSystem.Spacing.sm : 0)
        }
    }

    var emblemsSection: some View {
        VStack(spacing: 0) {
            Divider()
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.top, DesignSystem.Spacing.sm)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                sectionLabel("Symbols & Emblems")
                VStack(spacing: DesignSystem.Spacing.xs) {
                    ForEach(Array(symbolism.emblems.enumerated()), id: \.offset) { _, emblem in
                        emblemRow(emblem)
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.sm)
            .padding(.bottom, symbolism.historicalNote == nil ? DesignSystem.Spacing.sm : 0)
        }
    }

    func historicalNoteView(_ note: String) -> some View {
        VStack(spacing: 0) {
            Divider()
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.top, DesignSystem.Spacing.sm)

            HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 13))
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                    .frame(width: 20)
                    .padding(.top, 1)
                Text(note)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.sm)
            .padding(.bottom, DesignSystem.Spacing.sm)
        }
    }

    func colorRow(_ entry: FlagColorEntry) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .fill(Color(hex: entry.hex))
                .frame(width: 32, height: 32)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(entry.meaning)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }

    func emblemRow(_ emblem: FlagEmblemEntry) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .fill(DesignSystem.Color.cardBackgroundHighlighted)
                    .frame(width: 32, height: 32)
                Image(systemName: emblem.symbol)
                    .font(.system(size: 14))
                    .foregroundStyle(DesignSystem.Color.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(emblem.name)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(emblem.meaning)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }

    func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(DesignSystem.Font.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(DesignSystem.Color.textTertiary)
            .kerning(0.8)
    }
}

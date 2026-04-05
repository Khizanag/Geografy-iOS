import Geografy_Core_DesignSystem
import SwiftUI

public struct GeographyFeaturesScreen: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var selectedType: GeographyFeatureType = .mountain
    @State private var expandedFeatureId: String?
    @State private var blobAnimating = false

    private let service = GeographyFeaturesService()

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        scrollContent
            .background { ambientBlobs }
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle("Geography Features")
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .onAppear { blobAnimating = true }
    }
}

// MARK: - Subviews
private extension GeographyFeaturesScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                typePicker
                featureList
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
    }

    var typePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(GeographyFeatureType.allCases, id: \.rawValue) { type in
                    typeChip(type)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.xxs)
        }
    }

    func typeChip(_ type: GeographyFeatureType) -> some View {
        let isSelected = selectedType == type
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedType = type
                expandedFeatureId = nil
            }
        } label: {
            HStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: type.icon)
                    .font(DesignSystem.Font.caption)
                Text(type.displayName)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(
                isSelected ? DesignSystem.Color.accent : DesignSystem.Color.cardBackground,
                in: Capsule()
            )
        }
        .buttonStyle(.plain)
    }

    var featureList: some View {
        let items = service.features(for: selectedType)
        return VStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, feature in
                featureRow(feature: feature, rank: index + 1)
            }
        }
    }

    func featureRow(feature: GeographyFeature, rank: Int) -> some View {
        let isExpanded = expandedFeatureId == feature.id
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                expandedFeatureId = isExpanded ? nil : feature.id
            }
        } label: {
            CardView {
                VStack(spacing: 0) {
                    featureSummary(feature: feature, rank: rank, isExpanded: isExpanded)
                    if isExpanded {
                        featureDetail(feature: feature)
                    }
                }
            }
        }
        .buttonStyle(PressButtonStyle())
    }

    func featureSummary(feature: GeographyFeature, rank: Int, isExpanded: Bool) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            rankLabel(rank: rank)
            flagStack(codes: feature.countryCodes)
            featureInfo(feature: feature)
            Spacer(minLength: 0)
            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .accessibilityHidden(true)
        }
        .padding(DesignSystem.Spacing.sm)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Rank \(rank), \(feature.name), \(feature.measurementLabel): \(feature.formattedMeasurement)"
        )
        .accessibilityHint(isExpanded ? "Double tap to collapse" : "Double tap to expand")
    }

    func rankLabel(rank: Int) -> some View {
        Text("\(rank)")
            .font(DesignSystem.Font.caption)
            .fontWeight(.bold)
            .foregroundStyle(DesignSystem.Color.textTertiary)
            .frame(width: 24)
    }

    func flagStack(codes: [String]) -> some View {
        HStack(spacing: -6) {
            ForEach(codes.prefix(3), id: \.self) { code in
                FlagView(countryCode: code, height: 24)
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(DesignSystem.Color.cardBackground, lineWidth: 1)
                    )
            }
        }
    }

    func featureInfo(feature: GeographyFeature) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(feature.name)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(1)
            Text("\(feature.measurementLabel): \(feature.formattedMeasurement)")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }

    func featureDetail(feature: GeographyFeature) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Divider()
                .padding(.horizontal, DesignSystem.Spacing.sm)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(feature.description)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                HStack(alignment: .top, spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "lightbulb.fill")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.warning)
                        .accessibilityHidden(true)
                    Text(feature.funFact)
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
                Text(feature.continent)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(DesignSystem.Color.accent)
                    .padding(.horizontal, DesignSystem.Spacing.xs)
                    .padding(.vertical, 2)
                    .background(DesignSystem.Color.accent.opacity(0.12), in: Capsule())
            }
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.bottom, DesignSystem.Spacing.sm)
        }
    }

    var ambientBlobs: some View {
        ZStack {
            RadialGradient(
                colors: [DesignSystem.Color.blue.opacity(0.16), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 300
            )
            RadialGradient(
                colors: [DesignSystem.Color.indigo.opacity(0.12), .clear],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 280
            )
        }
        .ignoresSafeArea()
        .scaleEffect(blobAnimating ? 1.05 : 0.95)
        .animation(
            reduceMotion ? .default : .easeInOut(duration: 5).repeatForever(autoreverses: true),
            value: blobAnimating
        )
    }
}

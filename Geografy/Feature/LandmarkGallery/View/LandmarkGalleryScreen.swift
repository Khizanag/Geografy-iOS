import SwiftUI
import GeografyDesign

struct LandmarkGalleryScreen: View {
    @State private var selectedCategory: LandmarkCategory?
    @State private var selectedLandmark: Landmark?

    private let service = LandmarkGalleryService()

    private var displayedLandmarks: [Landmark] {
        service.landmarks(in: selectedCategory)
    }

    private let columns = [
        GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
        GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                categoryFilter
                landmarkGrid
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle("Landmark Gallery")
        .sheet(item: $selectedLandmark) { landmark in
            LandmarkDetailView(landmark: landmark)
        }
    }
}

// MARK: - Subviews
private extension LandmarkGalleryScreen {
    var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                filterChip(label: "All", icon: "globe", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(LandmarkCategory.allCases, id: \.self) { category in
                    filterChip(
                        label: category.displayName,
                        icon: category.icon,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = selectedCategory == category ? nil : category
                    }
                }
            }
        }
    }

    func filterChip(label: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(DesignSystem.Font.caption)
                Text(label)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(
                isSelected ? DesignSystem.Color.accent : DesignSystem.Color.cardBackground,
                in: Capsule()
            )
        }
        .buttonStyle(PressButtonStyle())
    }

    var landmarkGrid: some View {
        LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.sm) {
            ForEach(displayedLandmarks) { landmark in
                landmarkCard(landmark)
            }
        }
    }

    func landmarkCard(_ landmark: Landmark) -> some View {
        let accentColor = Color(hex: landmark.accentColor)
        return Button {
            selectedLandmark = landmark
        } label: {
            CardView {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    ZStack {
                        LinearGradient(
                            colors: [accentColor.opacity(0.4), accentColor.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        Image(systemName: landmark.symbolName)
                            .font(DesignSystem.Font.displayXXS)
                            .foregroundStyle(accentColor)
                    }
                    .frame(height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
                    VStack(spacing: 4) {
                        Text(landmark.name)
                            .font(DesignSystem.Font.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        HStack(spacing: 4) {
                            FlagView(countryCode: landmark.countryCode, height: 14)
                                .clipShape(RoundedRectangle(cornerRadius: 2))
                            Text(landmark.city)
                                .font(DesignSystem.Font.caption2)
                                .foregroundStyle(DesignSystem.Color.textSecondary)
                                .lineLimit(1)
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xs)
                    .padding(.bottom, DesignSystem.Spacing.xs)
                }
            }
        }
        .buttonStyle(PressButtonStyle())
    }
}

import SwiftUI
import GeografyDesign
import GeografyCore

struct HomeComingSoonSection: View {
    @Environment(HapticsService.self) private var hapticsService

    @AppStorage("comingSoonVotes") private var votesData: Data = Data()
    @State private var votes: [String: Int] = [:]
    @State private var votedFeature: String?

    private let features: [(icon: String, title: String, description: String, colors: [Color])] = [
        (
            "person.2.wave.2.fill",
            "Multiplayer Quiz",
            "Challenge friends in real-time",
            [Color(hex: "6C63FF"), Color(hex: "4DABF7")]
        ),
        (
            "calendar.badge.clock",
            "Daily Challenges",
            "Geography puzzles every day",
            [Color(hex: "FF6B6B"), Color(hex: "FFA500")]
        ),
        (
            "chart.bar.fill",
            "Country Compare",
            "Compare stats side by side",
            [Color(hex: "8E44AD"), Color(hex: "3498DB")]
        ),
        (
            "clock.arrow.trianglehead.counterclockwise.rotate.90",
            "Historical Maps",
            "Explore borders through time",
            [Color(hex: "C0392B"), Color(hex: "E74C3C")]
        ),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionHeader
            featuresGrid
        }
        .onAppear { loadVotes() }
    }
}

// MARK: - Subviews
private extension HomeComingSoonSection {
    var sectionHeader: some View {
        HStack {
            SectionHeaderView(title: "Coming Soon")
            Spacer()
            Text("Vote for what's next")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    var featuresGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: DesignSystem.Spacing.sm
        ) {
            ForEach(features, id: \.title) { feature in
                featureCard(feature)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    func featureCard(_ feature: (icon: String, title: String, description: String, colors: [Color])) -> some View {
        let voteCount = votes[feature.title, default: 0]
        let hasVoted = votedFeature == feature.title

        return Button {
            castVote(for: feature.title)
        } label: {
            ZStack(alignment: .bottomLeading) {
                LinearGradient(
                    colors: feature.colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Image(systemName: feature.icon)
                    .font(DesignSystem.IconSize.xxLarge)
                    .foregroundStyle(.white.opacity(0.09))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .offset(x: 10, y: -10)
                    .clipped()
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    voteBadge(count: voteCount, hasVoted: hasVoted)
                    Text(feature.title)
                        .font(DesignSystem.Font.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.Color.onAccent)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(feature.description)
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(.white.opacity(0.75))
                        .lineLimit(2)
                }
                .padding(DesignSystem.Spacing.sm)
            }
            .frame(height: 128)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        }
        .buttonStyle(PressButtonStyle())
    }

    func voteBadge(count: Int, hasVoted: Bool) -> some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: hasVoted ? "hand.thumbsup.fill" : "hand.thumbsup")
                .font(DesignSystem.Font.micro.bold())
            Text("\(count)")
                .font(DesignSystem.Font.caption2)
                .fontWeight(.bold)
                .contentTransition(.numericText())
        }
        .foregroundStyle(.white.opacity(hasVoted ? 1 : 0.8))
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .padding(.vertical, 2)
        .background(.white.opacity(hasVoted ? 0.35 : 0.2), in: Capsule())
    }
}

// MARK: - Actions
private extension HomeComingSoonSection {
    func castVote(for feature: String) {
        hapticsService.impact(.light)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            if votedFeature == feature {
                votes[feature, default: 0] = max(0, votes[feature, default: 0] - 1)
                votedFeature = nil
            } else {
                if let previous = votedFeature {
                    votes[previous, default: 0] = max(0, votes[previous, default: 0] - 1)
                }
                votes[feature, default: 0] += 1
                votedFeature = feature
            }
        }
        saveVotes()
    }

    func loadVotes() {
        guard !votesData.isEmpty,
              let decoded = try? JSONDecoder().decode([String: Int].self, from: votesData) else { return }
        votes = decoded
    }

    func saveVotes() {
        guard let encoded = try? JSONEncoder().encode(votes) else { return }
        votesData = encoded
    }
}

import Geografy_Core_Navigation
import Geografy_Core_Common
import Geografy_Core_Service
import Geografy_Core_DesignSystem
import SwiftUI

struct IndependenceTimelineScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(Navigator.self) private var coordinator

    @State private var selectedEra: IndependenceEra = .lateTwentieth
    @State private var selectedColonizer = ""
    @State private var blobAnimating = false

    private let service = IndependenceTimelineService()

    var body: some View {
        scrollContent
            .background { ambientBlobs }
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle("Independence Timeline")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { blobAnimating = true }
    }
}

// MARK: - Subviews
private extension IndependenceTimelineScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                eraFilter
                if !service.uniqueColonizers.isEmpty {
                    colonizerFilter
                }
                timelineList
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
    }

    var eraFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(IndependenceEra.allCases) { era in
                    eraChip(era)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.xxs)
        }
    }

    func eraChip(_ era: IndependenceEra) -> some View {
        let isSelected = selectedEra == era
        return Text(era.rawValue)
            .font(DesignSystem.Font.caption)
            .fontWeight(isSelected ? .semibold : .regular)
            .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(
                isSelected ? DesignSystem.Color.accent : DesignSystem.Color.cardBackground,
                in: Capsule()
            )
            .onTapGesture { selectedEra = era }
    }

    var colonizerFilter: some View {
        Menu {
            Button {
                selectedColonizer = ""
            } label: {
                Label(
                    "All countries",
                    systemImage: selectedColonizer.isEmpty ? "checkmark" : "globe"
                )
            }
            Divider()
            ForEach(service.uniqueColonizers, id: \.self) { colonizer in
                Button {
                    selectedColonizer = colonizer
                } label: {
                    Label(
                        colonizer,
                        systemImage: selectedColonizer == colonizer ? "checkmark" : "building.columns"
                    )
                }
            }
        } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                Text(selectedColonizer.isEmpty ? "All colonizers" : selectedColonizer)
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(DesignSystem.Font.caption)
            }
            .font(DesignSystem.Font.subheadline)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(DesignSystem.Color.accent.opacity(0.12), in: Capsule())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var timelineList: some View {
        let eraEvents = service.events(for: selectedEra)
        let filtered = selectedColonizer.isEmpty
            ? eraEvents
            : eraEvents.filter { $0.independenceFrom == selectedColonizer }
        return VStack(spacing: 0) {
            if filtered.isEmpty {
                emptyState
            } else {
                ForEach(Array(filtered.enumerated()), id: \.element.id) { index, event in
                    timelineRow(event: event, isLast: index == filtered.count - 1)
                }
            }
        }
    }

    var emptyState: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(DesignSystem.Font.displayXS)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            Text("No events found")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.xl)
    }

    func timelineRow(event: IndependenceEvent, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
            yearBadge(year: event.year)
            timelineConnector(isLast: isLast)
            eventCard(event: event)
        }
        .padding(.bottom, DesignSystem.Spacing.sm)
    }

    func yearBadge(year: Int) -> some View {
        Text(String(year))
            .font(DesignSystem.Font.caption)
            .fontWeight(.bold)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .padding(.vertical, 4)
            .background(DesignSystem.Color.accent, in: RoundedRectangle(cornerRadius: 6))
            .frame(width: 48)
    }

    func timelineConnector(isLast: Bool) -> some View {
        VStack(spacing: 0) {
            Circle()
                .fill(DesignSystem.Color.accent)
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            if !isLast {
                Rectangle()
                    .fill(DesignSystem.Color.accent.opacity(0.25))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
        }
    }

    func eventCard(event: IndependenceEvent) -> some View {
        Button { navigateToCountry(code: event.countryCode) } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    FlagView(countryCode: event.countryCode, height: 32)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    eventInfo(event: event)
                    Spacer(minLength: 0)
                }
                .padding(DesignSystem.Spacing.sm)
            }
        }
        .buttonStyle(PressButtonStyle())
    }

    func eventInfo(event: IndependenceEvent) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(event.countryName)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(1)
            Text("from \(event.independenceFrom)")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.accent)
                .lineLimit(1)
            Text(event.description)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(2)
        }
    }

    var ambientBlobs: some View {
        ZStack {
            RadialGradient(
                colors: [DesignSystem.Color.indigo.opacity(0.18), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 300
            )
            RadialGradient(
                colors: [DesignSystem.Color.accent.opacity(0.14), .clear],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 280
            )
        }
        .ignoresSafeArea()
        .scaleEffect(blobAnimating ? 1.05 : 0.95)
        .animation(
            reduceMotion ? .default : .easeInOut(duration: 4).repeatForever(autoreverses: true),
            value: blobAnimating
        )
    }
}

// MARK: - Actions
private extension IndependenceTimelineScreen {
    func navigateToCountry(code: String) {
        // Navigation to country detail handled via coordinator when country data is available
    }
}

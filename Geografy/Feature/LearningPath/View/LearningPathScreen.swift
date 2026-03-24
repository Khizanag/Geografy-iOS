import SwiftUI

struct LearningPathScreen: View {
    @Environment(LearningPathService.self) private var learningPathService

    @State private var selectedModule: LearningModule?
    @State private var blobAnimating = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                progressHeader
                pathContent
            }
            .padding(.vertical, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
        .background { ambientBlobs }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle("Learning Path")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedModule) { module in
            NavigationStack {
                ModuleLessonsScreen(module: module)
            }
            .presentationDetents([.large])
        }
        .onAppear { startBlobAnimation() }
    }
}

// MARK: - Subviews

private extension LearningPathScreen {
    var progressHeader: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Your Journey")
                            .font(DesignSystem.Font.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                        Text("\(completedModulesCount) of \(totalModulesCount) modules complete")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }
                    Spacer()
                    progressRingView(fraction: overallProgressFraction)
                }

                ProgressView(value: overallProgressFraction)
                    .tint(DesignSystem.Color.accent)
                    .background(DesignSystem.Color.cardBackgroundHighlighted, in: Capsule())
            }
            .padding(DesignSystem.Spacing.md)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    var pathContent: some View {
        VStack(spacing: 0) {
            ForEach(Array(learningPathService.modules.enumerated()), id: \.element.id) { index, module in
                moduleNode(module: module, index: index)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    func moduleNode(module: LearningModule, index: Int) -> some View {
        VStack(spacing: 0) {
            if index > 0 {
                connectorLine(unlocked: module.isUnlocked)
            }
            moduleCard(module: module)
        }
    }

    func connectorLine(unlocked: Bool) -> some View {
        Rectangle()
            .fill(
                unlocked
                    ? DesignSystem.Color.accent.opacity(0.5)
                    : DesignSystem.Color.textTertiary.opacity(0.25)
            )
            .frame(width: 2, height: DesignSystem.Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, DesignSystem.Spacing.md + 21)
    }

    func moduleCard(module: LearningModule) -> some View {
        Button {
            if module.isUnlocked {
                selectedModule = module
            }
        } label: {
            CardView {
                moduleCardContent(module: module)
            }
        }
        .buttonStyle(PressButtonStyle())
        .disabled(!module.isUnlocked)
        .opacity(module.isUnlocked ? 1 : 0.55)
    }

    func moduleCardContent(module: LearningModule) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            moduleIcon(module: module)
            moduleInfo(module: module)
            Spacer()
            moduleProgress(module: module)
        }
        .padding(DesignSystem.Spacing.md)
    }

    func moduleIcon(module: LearningModule) -> some View {
        ZStack {
            Circle()
                .fill(
                    module.isUnlocked
                        ? DesignSystem.Color.accent.opacity(0.15)
                        : DesignSystem.Color.textTertiary.opacity(0.12)
                )
                .frame(width: 44, height: 44)
            Image(systemName: module.isUnlocked ? module.icon : "lock.fill")
                .font(.system(size: 20))
                .foregroundStyle(
                    module.isUnlocked
                        ? DesignSystem.Color.accent
                        : DesignSystem.Color.textTertiary
                )
        }
    }

    func moduleInfo(module: LearningModule) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(module.title)
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(1)
            Text(module.description)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(2)
        }
    }

    func moduleProgress(module: LearningModule) -> some View {
        VStack(alignment: .trailing, spacing: 2) {
            if module.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(DesignSystem.Color.success)
            } else if module.isUnlocked {
                progressRingView(fraction: module.progressFraction)
                    .frame(width: 36, height: 36)
            }
            Text("\(module.completedCount)/\(module.totalCount)")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
    }

    func progressRingView(fraction: Double) -> some View {
        ZStack {
            Circle()
                .stroke(DesignSystem.Color.cardBackgroundHighlighted, lineWidth: 3)
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(DesignSystem.Color.accent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 36, height: 36)
        .animation(.easeOut(duration: 0.5), value: fraction)
    }

    var ambientBlobs: some View {
        ZStack {
            blobEllipse(color: DesignSystem.Color.accent, opacity: 0.20, offset: (-100, -200), animates: blobAnimating)
            blobEllipse(color: DesignSystem.Color.indigo, opacity: 0.18, offset: (160, 400), animates: !blobAnimating)
        }
        .allowsHitTesting(false)
    }

    func blobEllipse(color: Color, opacity: Double, offset: (CGFloat, CGFloat), animates: Bool) -> some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [color.opacity(opacity), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 200
                )
            )
            .frame(width: 400, height: 320)
            .blur(radius: 40)
            .offset(x: offset.0, y: offset.1)
            .scaleEffect(animates ? 1.08 : 0.92)
    }
}

// MARK: - Helpers

private extension LearningPathScreen {
    var completedModulesCount: Int {
        learningPathService.modules.filter { $0.isCompleted }.count
    }

    var totalModulesCount: Int {
        learningPathService.modules.count
    }

    var overallProgressFraction: Double {
        guard totalModulesCount > 0 else { return 0 }
        let totalLessons = learningPathService.modules.flatMap { $0.lessons }.count
        let completedLessons = learningPathService.modules.flatMap { $0.lessons }.filter { $0.isCompleted }.count
        guard totalLessons > 0 else { return 0 }
        return Double(completedLessons) / Double(totalLessons)
    }

    func startBlobAnimation() {
        withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
            blobAnimating = true
        }
    }
}

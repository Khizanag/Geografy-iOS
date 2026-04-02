import SwiftUI

public struct AmbientBlobsView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let preset: Preset

    @State private var isAnimating = false

    public init(_ preset: Preset = .standard) {
        self.preset = preset
    }

    public var body: some View {
        ZStack {
            ForEach(Array(preset.blobs.enumerated()), id: \.offset) { _, blob in
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [blob.color.opacity(blob.opacity), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: blob.endRadius
                        )
                    )
                    .frame(width: blob.width, height: blob.height)
                    .blur(radius: blob.blur)
                    .offset(x: blob.offset.width, y: blob.offset.height)
                    .scaleEffect(isAnimating ? blob.scaleRange.animating : blob.scaleRange.idle)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .ignoresSafeArea()
        .animation(
            reduceMotion ? nil : .easeInOut(duration: 6).repeatForever(autoreverses: true),
            value: isAnimating
        )
        .onAppear { isAnimating = true }
    }
}

// MARK: - Preset
public extension AmbientBlobsView {
    enum Preset {
        case standard
        case rich
        case quiz
        case subtle
        case leaderboard
        case tv
        case tvQuiz

        var blobs: [BlobDescriptor] {
            switch self {
            case .standard:
                [
                    BlobDescriptor(
                        color: DesignSystem.Color.accent,
                        opacity: 0.22,
                        width: 400,
                        height: 300,
                        blur: 36,
                        endRadius: 200,
                        offset: CGSize(width: -80, height: -100),
                        scaleRange: ScaleRange(idle: 0.90, animating: 1.10)
                    ),
                    BlobDescriptor(
                        color: DesignSystem.Color.indigo,
                        opacity: 0.18,
                        width: 360,
                        height: 300,
                        blur: 44,
                        endRadius: 180,
                        offset: CGSize(width: 140, height: 60),
                        scaleRange: ScaleRange(idle: 1.10, animating: 0.88)
                    ),
                ]

            case .rich:
                [
                    BlobDescriptor(
                        color: DesignSystem.Color.accent,
                        opacity: 0.22,
                        width: 420,
                        height: 320,
                        blur: 36,
                        endRadius: 200,
                        offset: CGSize(width: -80, height: -100),
                        scaleRange: ScaleRange(idle: 0.90, animating: 1.10)
                    ),
                    BlobDescriptor(
                        color: DesignSystem.Color.indigo,
                        opacity: 0.18,
                        width: 360,
                        height: 300,
                        blur: 44,
                        endRadius: 180,
                        offset: CGSize(width: 140, height: 60),
                        scaleRange: ScaleRange(idle: 1.10, animating: 0.88)
                    ),
                    BlobDescriptor(
                        color: DesignSystem.Color.purple,
                        opacity: 0.14,
                        width: 320,
                        height: 260,
                        blur: 40,
                        endRadius: 160,
                        offset: CGSize(width: -40, height: 400),
                        scaleRange: ScaleRange(idle: 0.95, animating: 1.05)
                    ),
                ]

            case .quiz:
                [
                    BlobDescriptor(
                        color: DesignSystem.Color.accent,
                        opacity: 0.22,
                        width: 420,
                        height: 320,
                        blur: 36,
                        endRadius: 200,
                        offset: CGSize(width: -80, height: -100),
                        scaleRange: ScaleRange(idle: 0.90, animating: 1.10)
                    ),
                    BlobDescriptor(
                        color: DesignSystem.Color.indigo,
                        opacity: 0.18,
                        width: 360,
                        height: 300,
                        blur: 44,
                        endRadius: 180,
                        offset: CGSize(width: 140, height: 60),
                        scaleRange: ScaleRange(idle: 1.10, animating: 0.88)
                    ),
                    BlobDescriptor(
                        color: DesignSystem.Color.blue,
                        opacity: 0.14,
                        width: 320,
                        height: 260,
                        blur: 40,
                        endRadius: 160,
                        offset: CGSize(width: -40, height: 400),
                        scaleRange: ScaleRange(idle: 0.95, animating: 1.05)
                    ),
                ]

            case .subtle:
                [
                    BlobDescriptor(
                        color: DesignSystem.Color.accent,
                        opacity: 0.14,
                        width: 400,
                        height: 300,
                        blur: 36,
                        endRadius: 200,
                        offset: CGSize(width: -60, height: -100),
                        scaleRange: ScaleRange(idle: 0.92, animating: 1.08)
                    ),
                    BlobDescriptor(
                        color: DesignSystem.Color.purple,
                        opacity: 0.10,
                        width: 320,
                        height: 260,
                        blur: 40,
                        endRadius: 160,
                        offset: CGSize(width: 120, height: 200),
                        scaleRange: ScaleRange(idle: 1.10, animating: 0.90)
                    ),
                ]

            case .leaderboard:
                [
                    BlobDescriptor(
                        color: DesignSystem.Color.accent,
                        opacity: 0.22,
                        width: 400,
                        height: 300,
                        blur: 32,
                        endRadius: 200,
                        offset: CGSize(width: -80, height: -60),
                        scaleRange: ScaleRange(idle: 0.90, animating: 1.10)
                    ),
                    BlobDescriptor(
                        color: DesignSystem.Color.warning,
                        opacity: 0.14,
                        width: 320,
                        height: 280,
                        blur: 40,
                        endRadius: 160,
                        offset: CGSize(width: 140, height: 120),
                        scaleRange: ScaleRange(idle: 1.10, animating: 0.88)
                    ),
                ]

            case .tv:
                [
                    BlobDescriptor(
                        color: DesignSystem.Color.accent,
                        opacity: 0.16,
                        width: 900,
                        height: 700,
                        blur: 80,
                        endRadius: 450,
                        offset: CGSize(width: -300, height: -200),
                        scaleRange: ScaleRange(idle: 0.90, animating: 1.10)
                    ),
                    BlobDescriptor(
                        color: DesignSystem.Color.indigo,
                        opacity: 0.12,
                        width: 800,
                        height: 600,
                        blur: 100,
                        endRadius: 400,
                        offset: CGSize(width: 400, height: 100),
                        scaleRange: ScaleRange(idle: 1.10, animating: 0.88)
                    ),
                    BlobDescriptor(
                        color: DesignSystem.Color.purple,
                        opacity: 0.08,
                        width: 700,
                        height: 500,
                        blur: 90,
                        endRadius: 350,
                        offset: CGSize(width: -100, height: 300),
                        scaleRange: ScaleRange(idle: 0.95, animating: 1.05)
                    ),
                ]

            case .tvQuiz:
                [
                    BlobDescriptor(
                        color: DesignSystem.Color.accent,
                        opacity: 0.18,
                        width: 1_000,
                        height: 700,
                        blur: 80,
                        endRadius: 500,
                        offset: CGSize(width: -300, height: -200),
                        scaleRange: ScaleRange(idle: 0.92, animating: 1.08)
                    ),
                    BlobDescriptor(
                        color: DesignSystem.Color.blue,
                        opacity: 0.12,
                        width: 800,
                        height: 600,
                        blur: 100,
                        endRadius: 400,
                        offset: CGSize(width: 500, height: 200),
                        scaleRange: ScaleRange(idle: 1.08, animating: 0.92)
                    ),
                ]
            }
        }
    }
}

// MARK: - Blob Descriptor
public extension AmbientBlobsView {
    struct ScaleRange {
        let idle: CGFloat
        let animating: CGFloat
    }

    struct BlobDescriptor {
        let color: Color
        let opacity: Double
        let width: CGFloat
        let height: CGFloat
        let blur: CGFloat
        let endRadius: CGFloat
        let offset: CGSize
        let scaleRange: ScaleRange
    }
}

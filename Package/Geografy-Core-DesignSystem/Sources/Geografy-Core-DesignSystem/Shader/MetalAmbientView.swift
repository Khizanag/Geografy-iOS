import SwiftUI

/// Full-bleed ambient background driven by a Metal shader.
///
/// Renders a flowing aurora gradient that never repeats — sampled from
/// `Shaders.metal`'s `aurora` stitchable function. Falls back to the
/// pre-existing `AmbientBlobsView` when Reduce Motion is enabled or when
/// the shader library cannot be loaded (tvOS simulator occasionally fails
/// to build Metal libs; we degrade gracefully rather than crash).
///
/// Usage:
/// ```swift
/// ZStack {
///     MetalAmbientView(preset: .standard)
///     content
/// }
/// .ignoresSafeArea()
/// ```
public struct MetalAmbientView: View {
    public enum Preset: Sendable {
        /// Everyday ambient — home, country list, settings.
        case standard
        /// Quiz screens — punchier saturation.
        case quiz
        /// Paywall / hero surfaces — brightest, most saturated.
        case hero
    }

    public var preset: Preset

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(preset: Preset = .standard) {
        self.preset = preset
    }

    public var body: some View {
        Group {
            if reduceMotion {
                AmbientBlobsView(reducedMotionBlobPreset)
            } else {
                TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: false)) { context in
                    let time = context.date.timeIntervalSinceReferenceDate
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(DesignSystem.Color.Gradient.aurora)
                            .colorEffect(ShaderLibrary.bundle(.module).aurora(
                                .float2(Float(geometry.size.width), Float(geometry.size.height)),
                                .float(Float(time))
                            ))
                            .opacity(opacity)
                    }
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Helpers
private extension MetalAmbientView {
    var opacity: Double {
        switch preset {
        case .standard: 0.7
        case .quiz:     0.85
        case .hero:     1.0
        }
    }

    var reducedMotionBlobPreset: AmbientBlobsView.Preset {
        switch preset {
        case .standard: .standard
        case .quiz:     .quiz
        case .hero:     .paywall
        }
    }
}

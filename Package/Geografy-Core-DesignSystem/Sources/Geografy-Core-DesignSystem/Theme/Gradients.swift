import SwiftUI

public extension DesignSystem.Color {
    /// Semantic gradient tokens derived from the existing asset-catalog palette.
    /// Prefer these over ad-hoc `LinearGradient(colors:)` call sites so the palette
    /// stays unified across screens and dark/light mode tracks automatically.
    enum Gradient {
        // MARK: - Linear gradients
        public static let aurora = LinearGradient(
            colors: [DesignSystem.Color.indigo, DesignSystem.Color.purple, DesignSystem.Color.blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        public static let ocean = LinearGradient(
            colors: [DesignSystem.Color.blue, DesignSystem.Color.ocean],
            startPoint: .top,
            endPoint: .bottom
        )

        public static let sunrise = LinearGradient(
            colors: [DesignSystem.Color.orange, DesignSystem.Color.warning],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        public static let dusk = LinearGradient(
            colors: [DesignSystem.Color.purple, DesignSystem.Color.indigo, DesignSystem.Color.ocean],
            startPoint: .top,
            endPoint: .bottom
        )

        public static let forest = LinearGradient(
            colors: [DesignSystem.Color.success, DesignSystem.Color.ocean],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        public static let volcano = LinearGradient(
            colors: [DesignSystem.Color.error, DesignSystem.Color.orange],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        public static let space = LinearGradient(
            colors: [DesignSystem.Color.indigo, DesignSystem.Color.background],
            startPoint: .top,
            endPoint: .bottom
        )

        // MARK: - Mesh gradients (iOS 26)
        /// Four-point mesh using the aurora palette — ideal for hero backgrounds.
        /// Time-driven variants live in the Shader module so this token stays pure.
        public static func auroraMesh() -> MeshGradient {
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    .init(0.0, 0.0), .init(0.5, 0.0), .init(1.0, 0.0),
                    .init(0.0, 0.5), .init(0.5, 0.5), .init(1.0, 0.5),
                    .init(0.0, 1.0), .init(0.5, 1.0), .init(1.0, 1.0),
                ],
                colors: [
                    DesignSystem.Color.indigo, DesignSystem.Color.purple, DesignSystem.Color.blue,
                    DesignSystem.Color.blue, DesignSystem.Color.indigo, DesignSystem.Color.purple,
                    DesignSystem.Color.indigo, DesignSystem.Color.blue, DesignSystem.Color.purple,
                ]
            )
        }

        public static func oceanMesh() -> MeshGradient {
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    .init(0.0, 0.0), .init(0.5, 0.0), .init(1.0, 0.0),
                    .init(0.0, 0.5), .init(0.5, 0.5), .init(1.0, 0.5),
                    .init(0.0, 1.0), .init(0.5, 1.0), .init(1.0, 1.0),
                ],
                colors: [
                    DesignSystem.Color.blue, DesignSystem.Color.ocean, DesignSystem.Color.blue,
                    DesignSystem.Color.ocean, DesignSystem.Color.blue, DesignSystem.Color.ocean,
                    DesignSystem.Color.blue, DesignSystem.Color.ocean, DesignSystem.Color.blue,
                ]
            )
        }

        public static func sunriseMesh() -> MeshGradient {
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    .init(0.0, 0.0), .init(0.5, 0.0), .init(1.0, 0.0),
                    .init(0.0, 0.5), .init(0.5, 0.5), .init(1.0, 0.5),
                    .init(0.0, 1.0), .init(0.5, 1.0), .init(1.0, 1.0),
                ],
                colors: [
                    DesignSystem.Color.orange, DesignSystem.Color.warning, DesignSystem.Color.orange,
                    DesignSystem.Color.warning, DesignSystem.Color.orange, DesignSystem.Color.warning,
                    DesignSystem.Color.orange, DesignSystem.Color.warning, DesignSystem.Color.orange,
                ]
            )
        }
    }
}

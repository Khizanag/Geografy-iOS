// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Geografy-Feature-Theme",
    platforms: [
        .iOS("26.0"),
        .tvOS("26.0"),
    ],
    products: [
        .library(
            name: "Geografy-Feature-Theme",
            targets: ["Geografy-Feature-Theme"]
        ),
    ],
    dependencies: [
        .package(path: "../../../Package/Geografy-Core-DesignSystem"),
    ],
    targets: [
        .target(
            name: "Geografy-Feature-Theme",
            dependencies: [
                .product(name: "Geografy-Core-DesignSystem", package: "Geografy-Core-DesignSystem"),
            ]
        ),
        .testTarget(
            name: "Geografy-Feature-ThemeTests",
            dependencies: ["Geografy-Feature-Theme"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

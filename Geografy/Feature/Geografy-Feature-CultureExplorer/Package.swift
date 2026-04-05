// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "Geografy-Feature-CultureExplorer",
    defaultLocalization: "en",
    platforms: [
        .iOS("26.0"),
        .tvOS("26.0"),
    ],
    products: [
        .library(
            name: "Geografy-Feature-CultureExplorer",
            targets: ["Geografy-Feature-CultureExplorer"]
        ),
    ],
    dependencies: [
        .package(path: "../../../Package/Geografy-Core-Common"),
        .package(path: "../../../Package/Geografy-Core-DesignSystem"),
    ],
    targets: [
        .target(
            name: "Geografy-Feature-CultureExplorer",
            dependencies: [
                .product(name: "Geografy-Core-Common", package: "Geografy-Core-Common"),
                .product(name: "Geografy-Core-DesignSystem", package: "Geografy-Core-DesignSystem"),
            ]
        ),
        .testTarget(
            name: "Geografy-Feature-CultureExplorerTests",
            dependencies: ["Geografy-Feature-CultureExplorer"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

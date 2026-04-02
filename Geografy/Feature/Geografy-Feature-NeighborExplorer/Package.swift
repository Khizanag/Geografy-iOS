// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Geografy-Feature-NeighborExplorer",
    defaultLocalization: "en",
    platforms: [
        .iOS("26.0"),
        .tvOS("26.0"),
    ],
    products: [
        .library(
            name: "Geografy-Feature-NeighborExplorer",
            targets: ["Geografy-Feature-NeighborExplorer"]
        ),
    ],
    dependencies: [
        .package(path: "../../../Package/Geografy-Core-Common"),
        .package(path: "../../../Package/Geografy-Core-DesignSystem"),
        .package(path: "../../../Package/Geografy-Core-Service"),
    ],
    targets: [
        .target(
            name: "Geografy-Feature-NeighborExplorer",
            dependencies: [
                .product(name: "Geografy-Core-Common", package: "Geografy-Core-Common"),
                .product(name: "Geografy-Core-DesignSystem", package: "Geografy-Core-DesignSystem"),
                .product(name: "Geografy-Core-Service", package: "Geografy-Core-Service"),
            ]
        ),
        .testTarget(
            name: "Geografy-Feature-NeighborExplorerTests",
            dependencies: ["Geografy-Feature-NeighborExplorer"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

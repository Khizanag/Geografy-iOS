// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Geografy-Feature-ContinentStats",
    platforms: [
        .iOS("26.0"),
        .tvOS("26.0"),
    ],
    products: [
        .library(
            name: "Geografy-Feature-ContinentStats",
            targets: ["Geografy-Feature-ContinentStats"]
        ),
    ],
    dependencies: [
        .package(path: "../../../Package/Geografy-Core-Common"),
        .package(path: "../../../Package/Geografy-Core-DesignSystem"),
        .package(path: "../../../Package/Geografy-Core-Navigation"),
        .package(path: "../../../Package/Geografy-Core-Service"),
    ],
    targets: [
        .target(
            name: "Geografy-Feature-ContinentStats",
            dependencies: [
                .product(name: "Geografy-Core-Common", package: "Geografy-Core-Common"),
                .product(name: "Geografy-Core-DesignSystem", package: "Geografy-Core-DesignSystem"),
                .product(name: "Geografy-Core-Navigation", package: "Geografy-Core-Navigation"),
                .product(name: "Geografy-Core-Service", package: "Geografy-Core-Service"),
            ]
        ),
        .testTarget(
            name: "Geografy-Feature-ContinentStatsTests",
            dependencies: ["Geografy-Feature-ContinentStats"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

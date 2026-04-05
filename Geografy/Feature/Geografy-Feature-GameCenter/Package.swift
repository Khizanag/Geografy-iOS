// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "Geografy-Feature-GameCenter",
    defaultLocalization: "en",
    platforms: [
        .iOS("26.0"),
        .tvOS("26.0"),
    ],
    products: [
        .library(
            name: "Geografy-Feature-GameCenter",
            targets: ["Geografy-Feature-GameCenter"]
        ),
    ],
    dependencies: [
        .package(path: "../../../Package/Geografy-Core-DesignSystem"),
        .package(path: "../../../Package/Geografy-Core-Navigation"),
        .package(path: "../../../Package/Geografy-Core-Service"),
    ],
    targets: [
        .target(
            name: "Geografy-Feature-GameCenter",
            dependencies: [
                .product(name: "Geografy-Core-DesignSystem", package: "Geografy-Core-DesignSystem"),
                .product(name: "Geografy-Core-Navigation", package: "Geografy-Core-Navigation"),
                .product(name: "Geografy-Core-Service", package: "Geografy-Core-Service"),
            ]
        ),
        .testTarget(
            name: "Geografy-Feature-GameCenterTests",
            dependencies: ["Geografy-Feature-GameCenter"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

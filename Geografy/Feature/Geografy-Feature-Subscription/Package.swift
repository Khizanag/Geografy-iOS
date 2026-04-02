// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Geografy-Feature-Subscription",
    defaultLocalization: "en",
    platforms: [
        .iOS("26.0"),
        .tvOS("26.0"),
    ],
    products: [
        .library(
            name: "Geografy-Feature-Subscription",
            targets: ["Geografy-Feature-Subscription"]
        ),
    ],
    dependencies: [
        .package(path: "../../../Package/Geografy-Core-DesignSystem"),
        .package(path: "../../../Package/Geografy-Core-Service"),
    ],
    targets: [
        .target(
            name: "Geografy-Feature-Subscription",
            dependencies: [
                .product(name: "Geografy-Core-DesignSystem", package: "Geografy-Core-DesignSystem"),
                .product(name: "Geografy-Core-Service", package: "Geografy-Core-Service"),
            ]
        ),
        .testTarget(
            name: "Geografy-Feature-SubscriptionTests",
            dependencies: ["Geografy-Feature-Subscription"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

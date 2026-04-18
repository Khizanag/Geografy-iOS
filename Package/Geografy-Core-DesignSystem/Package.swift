// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "Geografy-Core-DesignSystem",
    defaultLocalization: "en",
    platforms: [
        .iOS("26.0"),
        .tvOS("26.0"),
    ],
    products: [
        .library(
            name: "Geografy-Core-DesignSystem",
            targets: ["Geografy-Core-DesignSystem"]
        ),
    ],
    dependencies: [
        .package(path: "../Geografy-Core-Common"),
        .package(url: "https://github.com/airbnb/lottie-ios", from: "4.5.0"),
    ],
    targets: [
        .target(
            name: "Geografy-Core-DesignSystem",
            dependencies: [
                .product(name: "Geografy-Core-Common", package: "Geografy-Core-Common"),
                .product(name: "Lottie", package: "lottie-ios"),
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "Geografy-Core-DesignSystemTests",
            dependencies: ["Geografy-Core-DesignSystem"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

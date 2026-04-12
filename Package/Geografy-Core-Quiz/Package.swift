// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "Geografy-Core-Quiz",
    defaultLocalization: "en",
    platforms: [
        .iOS("26.0"),
        .tvOS("26.0"),
    ],
    products: [
        .library(
            name: "Geografy-Core-Quiz",
            targets: ["Geografy-Core-Quiz"]
        ),
    ],
    dependencies: [
        .package(path: "../Geografy-Core-Common"),
        .package(path: "../Geografy-Core-DesignSystem"),
    ],
    targets: [
        .target(
            name: "Geografy-Core-Quiz",
            dependencies: [
                .product(name: "Geografy-Core-Common", package: "Geografy-Core-Common"),
                .product(name: "Geografy-Core-DesignSystem", package: "Geografy-Core-DesignSystem"),
            ]
        ),
        .testTarget(
            name: "Geografy-Core-QuizTests",
            dependencies: ["Geografy-Core-Quiz"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

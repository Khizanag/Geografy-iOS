// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Geografy-Feature-LandmarkQuiz",
    defaultLocalization: "en",
    platforms: [
        .iOS("26.0"),
        .tvOS("26.0"),
    ],
    products: [
        .library(
            name: "Geografy-Feature-LandmarkQuiz",
            targets: ["Geografy-Feature-LandmarkQuiz"]
        ),
    ],
    dependencies: [
        .package(path: "../../../Package/Geografy-Core-Common"),
        .package(path: "../../../Package/Geografy-Core-DesignSystem"),
        .package(path: "../../../Package/Geografy-Core-Service"),
    ],
    targets: [
        .target(
            name: "Geografy-Feature-LandmarkQuiz",
            dependencies: [
                .product(name: "Geografy-Core-Common", package: "Geografy-Core-Common"),
                .product(name: "Geografy-Core-DesignSystem", package: "Geografy-Core-DesignSystem"),
                .product(name: "Geografy-Core-Service", package: "Geografy-Core-Service"),
            ]
        ),
        .testTarget(
            name: "Geografy-Feature-LandmarkQuizTests",
            dependencies: ["Geografy-Feature-LandmarkQuiz"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

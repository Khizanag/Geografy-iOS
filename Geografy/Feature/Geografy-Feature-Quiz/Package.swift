// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Geografy-Feature-Quiz",
    platforms: [
        .iOS("26.0"),
        .tvOS("26.0"),
    ],
    products: [
        .library(
            name: "Geografy-Feature-Quiz",
            targets: ["Geografy-Feature-Quiz"]
        ),
    ],
    dependencies: [
        .package(path: "../../../Package/Geografy-Core-Common"),
        .package(path: "../../../Package/Geografy-Core-DesignSystem"),
        .package(path: "../../../Package/Geografy-Core-Navigation"),
        .package(path: "../../../Package/Geografy-Core-Service"),
        .package(path: "../Geografy-Feature-NationalSymbols"),
    ],
    targets: [
        .target(
            name: "Geografy-Feature-Quiz",
            dependencies: [
                .product(name: "Geografy-Core-Common", package: "Geografy-Core-Common"),
                .product(name: "Geografy-Core-DesignSystem", package: "Geografy-Core-DesignSystem"),
                .product(name: "Geografy-Core-Navigation", package: "Geografy-Core-Navigation"),
                .product(name: "Geografy-Core-Service", package: "Geografy-Core-Service"),
                .product(name: "Geografy-Feature-NationalSymbols", package: "Geografy-Feature-NationalSymbols"),
            ]
        ),
        .testTarget(
            name: "Geografy-Feature-QuizTests",
            dependencies: ["Geografy-Feature-Quiz"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

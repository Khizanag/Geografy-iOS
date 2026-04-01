// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Geografy-Feature-CurrencyConverter",
    platforms: [
        .iOS("26.0"),
        .tvOS("26.0"),
    ],
    products: [
        .library(
            name: "Geografy-Feature-CurrencyConverter",
            targets: ["Geografy-Feature-CurrencyConverter"]
        ),
    ],
    dependencies: [
        .package(path: "../../../Package/Geografy-Core-DesignSystem"),
        .package(path: "../../../Package/Geografy-Core-Service"),
    ],
    targets: [
        .target(
            name: "Geografy-Feature-CurrencyConverter",
            dependencies: [
                .product(name: "Geografy-Core-DesignSystem", package: "Geografy-Core-DesignSystem"),
                .product(name: "Geografy-Core-Service", package: "Geografy-Core-Service"),
            ]
        ),
        .testTarget(
            name: "Geografy-Feature-CurrencyConverterTests",
            dependencies: ["Geografy-Feature-CurrencyConverter"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

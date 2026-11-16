// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "Geografy-Core-Map",
    defaultLocalization: "en",
    platforms: [
        .iOS("26.0"),
        .tvOS("26.0"),
    ],
    products: [
        .library(
            name: "Geografy-Core-Map",
            targets: ["Geografy-Core-Map"]
        ),
    ],
    dependencies: [
        .package(path: "../Geografy-Core-Common"),
        .package(path: "../Geografy-Core-DesignSystem"),
        .package(path: "../Geografy-Core-Service"),
    ],
    targets: [
        .target(
            name: "Geografy-Core-Map",
            dependencies: [
                .product(name: "Geografy-Core-Common", package: "Geografy-Core-Common"),
                .product(name: "Geografy-Core-DesignSystem", package: "Geografy-Core-DesignSystem"),
                .product(name: "Geografy-Core-Service", package: "Geografy-Core-Service"),
            ]
        ),
        .testTarget(
            name: "Geografy-Core-MapTests",
            dependencies: ["Geografy-Core-Map"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

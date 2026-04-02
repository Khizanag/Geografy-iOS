// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Geografy-Core-Service",
    defaultLocalization: "en",
    platforms: [
        .iOS("26.0"),
        .tvOS("26.0"),
    ],
    products: [
        .library(
            name: "Geografy-Core-Service",
            targets: ["Geografy-Core-Service"]
        ),
    ],
    dependencies: [
        .package(path: "../Geografy-Core-Common"),
        .package(path: "../Geografy-Core-DesignSystem"),
        .package(path: "../Geografy-Core-Navigation"),
    ],
    targets: [
        .target(
            name: "Geografy-Core-Service",
            dependencies: [
                .product(name: "Geografy-Core-Common", package: "Geografy-Core-Common"),
                .product(name: "Geografy-Core-DesignSystem", package: "Geografy-Core-DesignSystem"),
                .product(name: "Geografy-Core-Navigation", package: "Geografy-Core-Navigation"),
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "Geografy-Core-ServiceTests",
            dependencies: ["Geografy-Core-Service"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

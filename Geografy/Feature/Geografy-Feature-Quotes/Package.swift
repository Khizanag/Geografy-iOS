// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Geografy-Feature-Quotes",
    platforms: [
        .iOS("26.0"),
        .tvOS("26.0"),
    ],
    products: [
        .library(
            name: "Geografy-Feature-Quotes",
            targets: ["Geografy-Feature-Quotes"]
        ),
    ],
    dependencies: [
        .package(path: "../../../Package/Geografy-Core-Common"),
        .package(path: "../../../Package/Geografy-Core-DesignSystem"),
    ],
    targets: [
        .target(
            name: "Geografy-Feature-Quotes",
            dependencies: [
                .product(name: "Geografy-Core-Common", package: "Geografy-Core-Common"),
                .product(name: "Geografy-Core-DesignSystem", package: "Geografy-Core-DesignSystem"),
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "Geografy-Feature-QuotesTests",
            dependencies: ["Geografy-Feature-Quotes"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Geografy-Core-DesignSystem",
    products: [
        .library(
            name: "Geografy-Core-DesignSystem",
            targets: ["Geografy-Core-DesignSystem"]
        ),
    ],
    dependencies: [
        .package(path: "../Geografy-Core-Common"),
    ],
    targets: [
        .target(
            name: "Geografy-Core-DesignSystem",
            dependencies: [
                .product(name: "Geografy-Core-Common", package: "Geografy-Core-Common"),
            ]
        ),
        .testTarget(
            name: "Geografy-Core-DesignSystemTests",
            dependencies: ["Geografy-Core-DesignSystem"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

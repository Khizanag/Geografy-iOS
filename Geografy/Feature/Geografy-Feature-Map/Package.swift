// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Geografy-Feature-Map",
    products: [
        .library(
            name: "Geografy-Feature-Map",
            targets: ["Geografy-Feature-Map"]
        ),
    ],
    dependencies: [
        .package(path: "../../../Package/Geografy-Core-Common"),
        .package(path: "../../../Package/Geografy-Core-DesignSystem"),
    ],
    targets: [
        .target(
            name: "Geografy-Feature-Map",
            dependencies: [
                .product(name: "Geografy-Core-Common", package: "Geografy-Core-Common"),
                .product(name: "Geografy-Core-DesignSystem", package: "Geografy-Core-DesignSystem"),
            ]
        ),
        .testTarget(
            name: "Geografy-Feature-MapTests",
            dependencies: ["Geografy-Feature-Map"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

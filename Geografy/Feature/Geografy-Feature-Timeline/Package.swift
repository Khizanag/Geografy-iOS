// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Geografy-Feature-Timeline",
    platforms: [
        .iOS("26.0"),
        .tvOS("26.0"),
    ],
    products: [
        .library(
            name: "Geografy-Feature-Timeline",
            targets: ["Geografy-Feature-Timeline"]
        ),
    ],
    dependencies: [
        .package(path: "../../../Package/Geografy-Core-Common"),
        .package(path: "../../../Package/Geografy-Core-DesignSystem"),
        .package(path: "../../../Package/Geografy-Core-Navigation"),
        .package(path: "../../../Package/Geografy-Core-Service"),
        .package(path: "../Geografy-Feature-Map"),
    ],
    targets: [
        .target(
            name: "Geografy-Feature-Timeline",
            dependencies: [
                .product(name: "Geografy-Core-Common", package: "Geografy-Core-Common"),
                .product(name: "Geografy-Core-DesignSystem", package: "Geografy-Core-DesignSystem"),
                .product(name: "Geografy-Core-Navigation", package: "Geografy-Core-Navigation"),
                .product(name: "Geografy-Core-Service", package: "Geografy-Core-Service"),
                .product(name: "Geografy-Feature-Map", package: "Geografy-Feature-Map"),
            ]
        ),
        .testTarget(
            name: "Geografy-Feature-TimelineTests",
            dependencies: ["Geografy-Feature-Timeline"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Geografy-Feature-Travel",
    platforms: [
        .iOS("26.0"),
        .tvOS("26.0"),
    ],
    products: [
        .library(
            name: "Geografy-Feature-Travel",
            targets: ["Geografy-Feature-Travel"]
        ),
    ],
    dependencies: [
        .package(path: "../../../Package/Geografy-Core-Common"),
        .package(path: "../../../Package/Geografy-Core-DesignSystem"),
        .package(path: "../../../Package/Geografy-Core-Navigation"),
        .package(path: "../../../Package/Geografy-Core-Service"),
        .package(path: "../Geografy-Feature-CountryList"),
        .package(path: "../Geografy-Feature-Map"),
    ],
    targets: [
        .target(
            name: "Geografy-Feature-Travel",
            dependencies: [
                .product(name: "Geografy-Core-Common", package: "Geografy-Core-Common"),
                .product(name: "Geografy-Core-DesignSystem", package: "Geografy-Core-DesignSystem"),
                .product(name: "Geografy-Core-Navigation", package: "Geografy-Core-Navigation"),
                .product(name: "Geografy-Core-Service", package: "Geografy-Core-Service"),
                .product(name: "Geografy-Feature-CountryList", package: "Geografy-Feature-CountryList"),
                .product(name: "Geografy-Feature-Map", package: "Geografy-Feature-Map"),
            ]
        ),
        .testTarget(
            name: "Geografy-Feature-TravelTests",
            dependencies: ["Geografy-Feature-Travel"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

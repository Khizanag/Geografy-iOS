// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "Geografy-Feature-CountryDetail",
    defaultLocalization: "en",
    platforms: [
        .iOS("26.0"),
        .tvOS("26.0"),
    ],
    products: [
        .library(
            name: "Geografy-Feature-CountryDetail",
            targets: ["Geografy-Feature-CountryDetail"]
        ),
    ],
    dependencies: [
        .package(path: "../../../Package/Geografy-Core-Common"),
        .package(path: "../../../Package/Geografy-Core-DesignSystem"),
        .package(path: "../../../Package/Geografy-Core-Navigation"),
        .package(path: "../../../Package/Geografy-Core-Service"),
        .package(path: "../Geografy-Feature-CountryProfile"),
        .package(path: "../Geografy-Feature-Travel"),
    ],
    targets: [
        .target(
            name: "Geografy-Feature-CountryDetail",
            dependencies: [
                .product(name: "Geografy-Core-Common", package: "Geografy-Core-Common"),
                .product(name: "Geografy-Core-DesignSystem", package: "Geografy-Core-DesignSystem"),
                .product(name: "Geografy-Core-Navigation", package: "Geografy-Core-Navigation"),
                .product(name: "Geografy-Core-Service", package: "Geografy-Core-Service"),
                .product(name: "Geografy-Feature-CountryProfile", package: "Geografy-Feature-CountryProfile"),
                .product(name: "Geografy-Feature-Travel", package: "Geografy-Feature-Travel"),
            ]
        ),
        .testTarget(
            name: "Geografy-Feature-CountryDetailTests",
            dependencies: ["Geografy-Feature-CountryDetail"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Geografy-Feature-Auth",
    defaultLocalization: "en",
    platforms: [
        .iOS("26.0"),
        .tvOS("26.0"),
    ],
    products: [
        .library(
            name: "Geografy-Feature-Auth",
            targets: ["Geografy-Feature-Auth"]
        ),
    ],
    dependencies: [
        .package(path: "../../../Package/Geografy-Core-DesignSystem"),
        .package(path: "../../../Package/Geografy-Core-Navigation"),
        .package(path: "../../../Package/Geografy-Core-Service"),
    ],
    targets: [
        .target(
            name: "Geografy-Feature-Auth",
            dependencies: [
                .product(name: "Geografy-Core-DesignSystem", package: "Geografy-Core-DesignSystem"),
                .product(name: "Geografy-Core-Navigation", package: "Geografy-Core-Navigation"),
                .product(name: "Geografy-Core-Service", package: "Geografy-Core-Service"),
            ]
        ),
        .testTarget(
            name: "Geografy-Feature-AuthTests",
            dependencies: ["Geografy-Feature-Auth"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

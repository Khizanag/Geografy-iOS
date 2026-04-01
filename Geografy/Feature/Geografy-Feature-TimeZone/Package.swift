// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "Geografy-Feature-TimeZone",
    platforms: [
        .iOS(.v26),
        .tvOS(.v26),
    ],
    products: [
        .library(
            name: "Geografy-Feature-TimeZone",
            targets: ["Geografy-Feature-TimeZone"]
        ),
    ],
    dependencies: [
        .package(path: "../../../Package/Geografy-Core-Common"),
        .package(path: "../../../Package/Geografy-Core-DesignSystem"),
        .package(path: "../../../Package/Geografy-Core-Navigation"),
        .package(path: "../../../Package/Geografy-Core-Service"),
    ],
    targets: [
        .target(
            name: "Geografy-Feature-TimeZone",
            dependencies: [
                .product(name: "Geografy-Core-Common", package: "Geografy-Core-Common"),
                .product(name: "Geografy-Core-DesignSystem", package: "Geografy-Core-DesignSystem"),
                .product(name: "Geografy-Core-Navigation", package: "Geografy-Core-Navigation"),
                .product(name: "Geografy-Core-Service", package: "Geografy-Core-Service"),
            ]
        ),
        .testTarget(
            name: "Geografy-Feature-TimeZoneTests",
            dependencies: ["Geografy-Feature-TimeZone"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

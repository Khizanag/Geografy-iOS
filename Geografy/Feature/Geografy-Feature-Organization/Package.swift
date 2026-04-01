// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Geografy-Feature-Organization",
    platforms: [
        .iOS("26.0"),
        .tvOS("26.0"),
    ],
    products: [
        .library(
            name: "Geografy-Feature-Organization",
            targets: ["Geografy-Feature-Organization"]
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
            name: "Geografy-Feature-Organization",
            dependencies: [
                .product(name: "Geografy-Core-Common", package: "Geografy-Core-Common"),
                .product(name: "Geografy-Core-DesignSystem", package: "Geografy-Core-DesignSystem"),
                .product(name: "Geografy-Core-Navigation", package: "Geografy-Core-Navigation"),
                .product(name: "Geografy-Core-Service", package: "Geografy-Core-Service"),
            ]
        ),
        .testTarget(
            name: "Geografy-Feature-OrganizationTests",
            dependencies: ["Geografy-Feature-Organization"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

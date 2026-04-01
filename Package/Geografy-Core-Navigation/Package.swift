// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Geografy-Core-Navigation",
    platforms: [
        .iOS("26.0"),
        .tvOS("26.0"),
    ],
    products: [
        .library(
            name: "Geografy-Core-Navigation",
            targets: ["Geografy-Core-Navigation"]
        ),
    ],
    dependencies: [
        .package(path: "../Geografy-Core-Common"),
        .package(path: "../Geografy-Core-DesignSystem"),
    ],
    targets: [
        .target(
            name: "Geografy-Core-Navigation",
            dependencies: [
                .product(name: "Geografy-Core-Common", package: "Geografy-Core-Common"),
                .product(name: "Geografy-Core-DesignSystem", package: "Geografy-Core-DesignSystem"),
            ]
        ),
        .testTarget(
            name: "Geografy-Core-NavigationTests",
            dependencies: ["Geografy-Core-Navigation"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

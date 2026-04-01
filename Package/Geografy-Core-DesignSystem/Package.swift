// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "Geografy-Core-DesignSystem",
    platforms: [
        .iOS(.v26),
        .tvOS(.v26),
    ],
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

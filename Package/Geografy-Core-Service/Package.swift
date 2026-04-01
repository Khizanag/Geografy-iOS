// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "Geografy-Core-Service",
    platforms: [
        .iOS(.v26),
        .tvOS(.v26),
    ],
    products: [
        .library(
            name: "Geografy-Core-Service",
            targets: ["Geografy-Core-Service"]
        ),
    ],
    dependencies: [
        .package(path: "../Geografy-Core-Common"),
        .package(path: "../Geografy-Core-DesignSystem"),
    ],
    targets: [
        .target(
            name: "Geografy-Core-Service",
            dependencies: [
                .product(name: "Geografy-Core-Common", package: "Geografy-Core-Common"),
                .product(name: "Geografy-Core-DesignSystem", package: "Geografy-Core-DesignSystem"),
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "Geografy-Core-ServiceTests",
            dependencies: ["Geografy-Core-Service"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

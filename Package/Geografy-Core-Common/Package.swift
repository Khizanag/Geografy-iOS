// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Geografy-Core-Common",
    defaultLocalization: "en",
    platforms: [
        .iOS("26.0"),
        .tvOS("26.0"),
    ],
    products: [
        .library(
            name: "Geografy-Core-Common",
            targets: ["Geografy-Core-Common"]
        ),
    ],
    targets: [
        .target(
            name: "Geografy-Core-Common",
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "Geografy-Core-CommonTests",
            dependencies: ["Geografy-Core-Common"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

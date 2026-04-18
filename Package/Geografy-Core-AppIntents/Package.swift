// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "Geografy-Core-AppIntents",
    defaultLocalization: "en",
    platforms: [
        .iOS("26.0"),
    ],
    products: [
        .library(
            name: "Geografy-Core-AppIntents",
            targets: ["Geografy-Core-AppIntents"]
        ),
    ],
    targets: [
        .target(name: "Geografy-Core-AppIntents"),
        .testTarget(
            name: "Geografy-Core-AppIntentsTests",
            dependencies: ["Geografy-Core-AppIntents"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

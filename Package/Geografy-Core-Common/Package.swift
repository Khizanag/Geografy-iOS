// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Geografy-Core-Common",
    products: [
        .library(
            name: "Geografy-Core-Common",
            targets: ["Geografy-Core-Common"]
        ),
    ],
    targets: [
        .target(
            name: "Geografy-Core-Common"
        ),
        .testTarget(
            name: "Geografy-Core-CommonTests",
            dependencies: ["Geografy-Core-Common"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

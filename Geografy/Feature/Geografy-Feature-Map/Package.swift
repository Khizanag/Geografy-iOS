// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "Geografy-Feature-Map",
    products: [
        .library(
            name: "Geografy-Feature-Map",
            targets: ["Geografy-Feature-Map"]
        ),
    ],
    dependencies: [
        .package(path: "../../../Package/GeografyCore"),
        .package(path: "../../../Package/GeografyDesign"),
    ],
    targets: [
        .target(
            name: "Geografy-Feature-Map",
            dependencies: [
                .product(name: "GeografyCore", package: "GeografyCore"),
                .product(name: "GeografyDesign", package: "GeografyDesign"),
            ]
        ),
        .testTarget(
            name: "Geografy-Feature-MapTests",
            dependencies: ["Geografy-Feature-Map"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

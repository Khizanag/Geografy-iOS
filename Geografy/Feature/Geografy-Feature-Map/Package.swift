// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "Geografy-Feature-Map",
    platforms: [
        .iOS(.v26),
        .tvOS(.v26),
    ],
    products: [
        .library(
            name: "Geografy-Feature-Map",
            targets: ["Geografy-Feature-Map"]
        ),
    ],
    dependencies: [
        .package(path: "../../../Package/GeografyCore"),
        .package(path: "../../../Package/GeografyDesign"),
        .package(path: "../../../Package/Geografy-Core-Service"),
    ],
    targets: [
        .target(
            name: "Geografy-Feature-Map",
            dependencies: [
                .product(name: "GeografyCore", package: "GeografyCore"),
                .product(name: "GeografyDesign", package: "GeografyDesign"),
                .product(name: "Geografy-Core-Service", package: "Geografy-Core-Service"),
            ]
        ),
        .testTarget(
            name: "Geografy-Feature-MapTests",
            dependencies: ["Geografy-Feature-Map"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

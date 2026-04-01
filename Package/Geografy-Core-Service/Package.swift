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
        .package(path: "../GeografyCore"),
        .package(path: "../GeografyDesign"),
    ],
    targets: [
        .target(
            name: "Geografy-Core-Service",
            dependencies: [
                .product(name: "GeografyCore", package: "GeografyCore"),
                .product(name: "GeografyDesign", package: "GeografyDesign"),
            ]
        ),
        .testTarget(
            name: "Geografy-Core-ServiceTests",
            dependencies: ["Geografy-Core-Service"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

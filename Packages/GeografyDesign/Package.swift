// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "GeografyDesign",
    platforms: [
        .iOS(.v26),
        .tvOS(.v26),
    ],
    products: [
        .library(name: "GeografyDesign", targets: ["GeografyDesign"]),
    ],
    dependencies: [
        .package(path: "../GeografyCore"),
    ],
    targets: [
        .target(
            name: "GeografyDesign",
            dependencies: ["GeografyCore"]
        ),
    ]
)

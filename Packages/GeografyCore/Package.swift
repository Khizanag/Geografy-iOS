// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "GeografyCore",
    platforms: [
        .iOS(.v26),
        .tvOS(.v26),
    ],
    products: [
        .library(name: "GeografyCore", targets: ["GeografyCore"]),
    ],
    targets: [
        .target(name: "GeografyCore"),
    ]
)

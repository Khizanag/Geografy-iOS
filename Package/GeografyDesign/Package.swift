// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GeografyDesign",
    platforms: [
        .iOS(.v26),
        .tvOS(.v26),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GeografyDesign",
            targets: ["GeografyDesign"]
        ),
    ],
    dependencies: [
        .package(path: "../GeografyCore"),
    ],
    targets: [
        .target(
            name: "GeografyDesign",
            dependencies: ["GeografyCore"]
        ),
        .testTarget(
            name: "GeografyDesignTests",
            dependencies: ["GeografyDesign"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Geografy-Feature-LandmarkGallery",
    platforms: [
        .iOS("26.0"),
        .tvOS("26.0"),
    ],
    products: [
        .library(
            name: "Geografy-Feature-LandmarkGallery",
            targets: ["Geografy-Feature-LandmarkGallery"]
        ),
    ],
    dependencies: [
        .package(path: "../../../Package/Geografy-Core-Common"),
        .package(path: "../../../Package/Geografy-Core-DesignSystem"),
    ],
    targets: [
        .target(
            name: "Geografy-Feature-LandmarkGallery",
            dependencies: [
                .product(name: "Geografy-Core-Common", package: "Geografy-Core-Common"),
                .product(name: "Geografy-Core-DesignSystem", package: "Geografy-Core-DesignSystem"),
            ]
        ),
        .testTarget(
            name: "Geografy-Feature-LandmarkGalleryTests",
            dependencies: ["Geografy-Feature-LandmarkGallery"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

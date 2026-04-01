// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Geografy-Feature-LanguageExplorer",
    platforms: [
        .iOS("26.0"),
        .tvOS("26.0"),
    ],
    products: [
        .library(
            name: "Geografy-Feature-LanguageExplorer",
            targets: ["Geografy-Feature-LanguageExplorer"]
        ),
    ],
    dependencies: [
        .package(path: "../../../Package/Geografy-Core-Common"),
        .package(path: "../../../Package/Geografy-Core-DesignSystem"),
    ],
    targets: [
        .target(
            name: "Geografy-Feature-LanguageExplorer",
            dependencies: [
                .product(name: "Geografy-Core-Common", package: "Geografy-Core-Common"),
                .product(name: "Geografy-Core-DesignSystem", package: "Geografy-Core-DesignSystem"),
            ]
        ),
        .testTarget(
            name: "Geografy-Feature-LanguageExplorerTests",
            dependencies: ["Geografy-Feature-LanguageExplorer"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

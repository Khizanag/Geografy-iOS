// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "Geografy-Feature-QuizLibrary",
    defaultLocalization: "en",
    platforms: [
        .iOS("26.0"),
        .tvOS("26.0"),
    ],
    products: [
        .library(
            name: "Geografy-Feature-QuizLibrary",
            targets: ["Geografy-Feature-QuizLibrary"]
        ),
    ],
    dependencies: [
        .package(path: "../../../Package/Geografy-Core-Common"),
        .package(path: "../../../Package/Geografy-Core-DesignSystem"),
        .package(path: "../../../Package/Geografy-Core-Navigation"),
        .package(path: "../../../Package/Geografy-Core-Service"),
        .package(path: "../Geografy-Feature-CountryList"),
    ],
    targets: [
        .target(
            name: "Geografy-Feature-QuizLibrary",
            dependencies: [
                .product(name: "Geografy-Core-Common", package: "Geografy-Core-Common"),
                .product(name: "Geografy-Core-DesignSystem", package: "Geografy-Core-DesignSystem"),
                .product(name: "Geografy-Core-Navigation", package: "Geografy-Core-Navigation"),
                .product(name: "Geografy-Core-Service", package: "Geografy-Core-Service"),
                .product(name: "Geografy-Feature-CountryList", package: "Geografy-Feature-CountryList"),
            ]
        ),
        .testTarget(
            name: "Geografy-Feature-QuizLibraryTests",
            dependencies: ["Geografy-Feature-QuizLibrary"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

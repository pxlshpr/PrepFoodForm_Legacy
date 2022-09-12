// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PrepFoodForm",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PrepFoodForm",
            targets: ["PrepFoodForm"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/pxlshpr/ISEmojiView", from: "0.3.3"),
        .package(url: "https://github.com/pxlshpr/NamePicker", from: "0.0.5"),
        .package(url: "https://github.com/pxlshpr/SwiftUISugar", from: "0.0.168"),
        .package(url: "https://github.com/pxlshpr/CodeScanner", from: "0.0.7"),
        .package(url: "https://github.com/pxlshpr/CameraImagePicker", from: "0.0.1"),
        .package(url: "https://github.com/pxlshpr/PrepUnits", from: "0.0.46"),
        .package(url: "https://github.com/yeahdongcn/RSBarcodes_Swift", from: "5.1.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PrepFoodForm",
            dependencies: [
                .product(name: "ISEmojiView", package: "isemojiview"),
                .product(name: "NamePicker", package: "namepicker"),
                .product(name: "SwiftUISugar", package: "swiftuisugar"),
                .product(name: "CodeScanner", package: "codescanner"),
                .product(name: "CameraImagePicker", package: "cameraimagepicker"),
                .product(name: "PrepUnits", package: "prepunits"),
                .product(name: "RSBarcodes_Swift", package: "rsbarcodes_swift")
            ]),
        .testTarget(
            name: "PrepFoodFormTests",
            dependencies: ["PrepFoodForm"]),
    ]
)

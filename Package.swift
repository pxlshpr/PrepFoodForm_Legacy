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
        .package(url: "https://github.com/pxlshpr/SwiftUICamera", from: "0.0.27"),
        .package(url: "https://github.com/pxlshpr/FoodLabelCamera", from: "0.0.1"),
        .package(url: "https://github.com/pxlshpr/FoodLabelScanner", from: "0.0.43"),
        .package(url: "https://github.com/pxlshpr/FoodLabel", from: "0.0.23"),
        .package(url: "https://github.com/pxlshpr/MFPScraper", from: "0.0.54"),
        .package(url: "https://github.com/pxlshpr/EmojiPicker", from: "0.0.8"),
        .package(url: "https://github.com/pxlshpr/NamePicker", from: "0.0.17"),
        .package(url: "https://github.com/pxlshpr/SwiftUISugar", from: "0.0.185"),
        .package(url: "https://github.com/pxlshpr/PrepUnits", from: "0.0.68"),
        .package(url: "https://github.com/pxlshpr/VisionSugar", from: "0.0.54"),
        .package(url: "https://github.com/yeahdongcn/RSBarcodes_Swift", from: "5.1.1"),
        .package(url: "https://github.com/exyte/ActivityIndicatorView", from: "1.1.0"),
        .package(url: "https://github.com/fermoya/SwiftUIPager", from: "2.5.0"),
        .package(url: "https://github.com/pxlshpr/ZoomableScrollView", from: "0.0.19"),
        .package(url: "https://github.com/siteline/SwiftUI-Introspect", from: "0.1.4"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PrepFoodForm",
            dependencies: [
                .product(name: "Camera", package: "swiftuicamera"),
                .product(name: "FoodLabelScanner", package: "foodlabelscanner"),
                .product(name: "FoodLabelCamera", package: "foodlabelcamera"),
                .product(name: "EmojiPicker", package: "emojipicker"),
                .product(name: "NamePicker", package: "namepicker"),
                .product(name: "SwiftUISugar", package: "swiftuisugar"),
                .product(name: "MFPScraper", package: "mfpscraper"),
                .product(name: "PrepUnits", package: "prepunits"),
                .product(name: "VisionSugar", package: "visionsugar"),
                .product(name: "FoodLabel", package: "foodlabel"),
                .product(name: "RSBarcodes_Swift", package: "rsbarcodes_swift"),
                .product(name: "ActivityIndicatorView", package: "activityindicatorview"),
                .product(name: "SwiftUIPager", package: "swiftuipager"),
                .product(name: "ZoomableScrollView", package: "zoomablescrollview"),
                .product(name: "Introspect", package: "swiftui-introspect"),
            ],
            resources: [.process("SampleImages")]
        ),
        .testTarget(
            name: "PrepFoodFormTests",
            dependencies: ["PrepFoodForm"]),
    ]
)

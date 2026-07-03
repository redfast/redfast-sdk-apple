// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "RedFast",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15),
    ],
    products: [
        // Core only — use if you need SDK logic without any UI components.
        .library(
            name: "redfast-core",
            targets: ["redfast-core"]
        ),
        // UI only — SwiftUI components with no StoreKit dependency.
        .library(
            name: "redfast-ui",
            targets: ["redfast-ui"]
        ),
        // UI + in-app purchases — requires redfast-core and redfast-ui.
        .library(
            name: "redfast-ui-iap",
            targets: ["redfast-ui-iap"]
        ),
        // UI + push notifications — requires redfast-core and redfast-ui.
        .library(
            name: "redfast-ui-push",
            targets: ["redfast-ui-push"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "redfast-core",
            url: "https://github.com/recurly/redfast-sdk-apple/releases/download/3.0.0-pre-release/redfast-core-3.0.0.xcframework.zip",
            checksum: "d978995ae718ab154d092d54f80bdc265c70780e5591be607f6e913d28638236"
        ),
        .binaryTarget(
            name: "redfast-ui",
            url: "https://github.com/recurly/redfast-sdk-apple/releases/download/3.0.0-pre-release/redfast-ui-3.0.0.xcframework.zip",
            checksum: "666c18a08dcbc40fc873c90421ea531f5342b9b11dd02cdfc64793811eb9d1bf"
        ),
        .binaryTarget(
            name: "redfast-ui-iap",
            url: "https://github.com/recurly/redfast-sdk-apple/releases/download/3.0.0-pre-release/redfast-ui-iap-3.0.0.xcframework.zip",
            checksum: "004e14884758dffac7e767fbf9ae97587640af07fba890e789493ce6a6ca2469"
        ),
        .binaryTarget(
            name: "redfast-ui-push",
            url: "https://github.com/recurly/redfast-sdk-apple/releases/download/3.0.0-pre-release/redfast-ui-push-3.0.0.xcframework.zip",
            checksum: "9463a703364119f291275660fe5ce1e6c1b15e03bda494bf1f70f91c9f038915"
        ),
    ]
)
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
        // Use this if you only need UI components (no IAP, no push).
        .library(
            name: "redfast-ui",
            targets: ["redfast-ui-complete"]
        ),
        // Use this if you need UI + in-app purchases (StoreKit 2).
        .library(
            name: "redfast-ui-iap",
            targets: ["redfast-ui-iap-complete"]
        ),
        // Use this if you need UI + push notifications (APNs/FCM).
        .library(
            name: "redfast-ui-push",
            targets: ["redfast-ui-push-complete"]
        ),
    ],
    targets: [
        // MARK: - Binary targets
        .binaryTarget(
            name: "redfast-core",
            url: "https://github.com/recurly/redfast-sdk-apple/releases/download/3.0.0-pre-release/redfast-core-3.0.0.xcframework.zip",
            checksum: "2a46bcece27e7f6892209e967ceefb01dc36efe28936d42f6b1192fc86e9444b"
        ),
        .binaryTarget(
            name: "redfast-ui",
            url: "https://github.com/recurly/redfast-sdk-apple/releases/download/3.0.0-pre-release/redfast-ui-3.0.0.xcframework.zip",
            checksum: "58d04ae0e0fae7bb62e0f58f5e8b4858c843b644add133b6debc9933155594e9"
        ),
        .binaryTarget(
            name: "redfast-ui-iap",
            url: "https://github.com/recurly/redfast-sdk-apple/releases/download/3.0.0-pre-release/redfast-ui-iap-3.0.0.xcframework.zip",
            checksum: "5956c887e70276bb54c6abc23b14a2df170cc60ccd22561a931593af76769e12"
        ),
        .binaryTarget(
            name: "redfast-ui-push",
            url: "https://github.com/recurly/redfast-sdk-apple/releases/download/3.0.0-pre-release/redfast-ui-push-3.0.0.xcframework.zip",
            checksum: "7bc1f86d288224cb47b7f5490daaecb69adb044dfdb501dadb2e1fea77531ba2"
        ),

        // MARK: - Wrapper targets
        // These expose clean product names and bundle all required dependencies.
        .target(
            name: "redfast-ui-complete",
            dependencies: ["redfast-core", "redfast-ui"],
            path: "Sources/redfast-ui-complete"
        ),
        .target(
            name: "redfast-ui-iap-complete",
            dependencies: ["redfast-core", "redfast-ui", "redfast-ui-iap"],
            path: "Sources/redfast-ui-iap-complete"
        ),
        .target(
            name: "redfast-ui-push-complete",
            dependencies: ["redfast-core", "redfast-ui", "redfast-ui-push"],
            path: "Sources/redfast-ui-push-complete"
        ),
    ]
)
// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "RedFast",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15),
    ],
    products: [
        .library(
            name: "redfast_core",     
            targets: ["redfast_core"]),
        .library(
            name: "redfast_ui",       
            targets: ["redfast_ui"]),
        .library(
            name: "redfast_ui_iap",   
            targets: ["redfast_ui_iap"]),
        .library(
            name: "redfast_ui_push",  
            targets: ["redfast_ui_push"]),
    ],
    targets: [
        .binaryTarget(
            name: "redfast_core",
            url: "https://github.com/recurly/redfast-sdk-apple/releases/download/3.0.0/redfast-core-3.0.0.xcframework.zip",
            checksum: "a36f1904a2cdbbf1b5b68d3ba274beb741d5ff7dcaa3057812116973fa70904e"
        ),
        .binaryTarget(
            name: "redfast_ui",
            url: "https://github.com/recurly/redfast-sdk-apple/releases/download/3.0.0/redfast-ui-3.0.0.xcframework.zip",
            checksum: "1f994ed55b29a5d1848fe6530f22d85695b53ef072e8011fa07f608f43f0ca46"
        ),
        .binaryTarget(
            name: "redfast_ui_iap",
            url: "https://github.com/recurly/redfast-sdk-apple/releases/download/3.0.0/redfast-ui-iap-3.0.0.xcframework.zip",
            checksum: "431f5ffe1f76e155ca81a7b0b498d3839f2457bb2537bb9b3d9660dbf15c118b"
        ),
        .binaryTarget(
            name: "redfast_ui_push",
            url: "https://github.com/recurly/redfast-sdk-apple/releases/download/3.0.0/redfast-ui-push-3.0.0.xcframework.zip",
            checksum: "ab2f1e4affa825b097fb5ac2d20da9e654ca1f711503950101d4a0ba42021cb6"
        ),
    ]
)

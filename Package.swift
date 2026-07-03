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
            url: "https://github.com/recurly/redfast-sdk-apple/releases/download/3.0.0-pre-release/redfast-core-3.0.0.xcframework.zip",
            checksum: "d84c60e1f8113b72fd8cf302f9d05d8a6708720a2adc51986cf1dccac81b119e"
        ),
        .binaryTarget(
            name: "redfast_ui",
            url: "https://github.com/recurly/redfast-sdk-apple/releases/download/3.0.0-pre-release/redfast-ui-3.0.0.xcframework.zip",
            checksum: "d19a9675d962833f0297e10f2e9af38eb1a450e02612fe628cdff0cd75ee650f"
        ),
        .binaryTarget(
            name: "redfast_ui_iap",
            url: "https://github.com/recurly/redfast-sdk-apple/releases/download/3.0.0-pre-release/redfast-ui-iap-3.0.0.xcframework.zip",
            checksum: "c8521415680e0f1e6e02247ea1f6b1feef52563de3c32c54425548c12cd03d99"
        ),
        .binaryTarget(
            name: "redfast_ui_push",
            url: "https://github.com/recurly/redfast-sdk-apple/releases/download/3.0.0-pre-release/redfast-ui-push-3.0.0.xcframework.zip",
            checksum: "1676b84b1fb9f792c819b92a6fa4fcf241e0b3eaf76d5a21875e073476e44279"
        ),
    ]
)

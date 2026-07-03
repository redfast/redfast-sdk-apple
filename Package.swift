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
            checksum: "666cd0769f3b848fb4c065820bfe818b6db0c293609142c1db6efccbb45c2a73"
        ),
        .binaryTarget(
            name: "redfast_ui",
            url: "https://github.com/recurly/redfast-sdk-apple/releases/download/3.0.0-pre-release/redfast-ui-3.0.0.xcframework.zip",
            checksum: "d4cfa9449b0b4c94776e46ae0bba7aabb07205f7f5e69bc7193b0f6866946ec2"
        ),
        .binaryTarget(
            name: "redfast_ui_iap",
            url: "https://github.com/recurly/redfast-sdk-apple/releases/download/3.0.0-pre-release/redfast-ui-iap-3.0.0.xcframework.zip",
            checksum: "8604bf7134011c01178004bd42ad9ca61e3d9f3d61b6f15cdbf152cc9836aef0"
        ),
        .binaryTarget(
            name: "redfast_ui_push",
            url: "https://github.com/recurly/redfast-sdk-apple/releases/download/3.0.0-pre-release/redfast-ui-push-3.0.0.xcframework.zip",
            checksum: "dd7dc08d40e1bfbc15782ccf26d82a33330b107e16b3fdc7eddd6bfd3753c0b4"
        ),
    ]
)

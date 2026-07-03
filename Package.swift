// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RedFast",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "RedFast",
            targets: ["RedFast"]),
        // Opt-in flavor that adds Firebase Cloud Messaging push support. Link this instead of
        // "RedFast" (not both) when Firebase push is needed.
        .library(
            name: "RedFastFirebase",
            targets: ["RedFastFirebase"])
    ],
    dependencies: [],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(
            name: "RedFast",
            url: "https://github.com/recurly/redfast-sdk-apple/releases/download/2.3.17/RedFast.xcframework.zip",
            checksum: "0bf9c98fa303554feacfbb82fb75c4754bbf89753db0dc19d2fccd3d19155d84"),
        .binaryTarget(
            name: "RedFastFirebase",
            url: "https://github.com/recurly/redfast-sdk-apple/releases/download/2.3.17/RedFastFirebase.xcframework.zip",
            checksum: "28619cf03b5d0904bbc79a2f94aa08615c897d03ce006f3923532351edf6d13e")
    ]
)

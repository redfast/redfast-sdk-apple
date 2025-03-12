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
            targets: ["RedFast"])
    ],
    dependencies: [],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(
            name: "RedFast",
            url: "https://github.com/redfast/redfast-sdk-apple/releases/download/2.2.2/RedFast.xcframework.zip",
            checksum: "4d06c7493e9ff4c61c00a5737c7422b2663d145d5a9a5c770ebdf9e567be8605"),
    ]
)

// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MindBoxPackage",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.

    .library(
      name: "AppFeature",
      targets: ["AppFeature"]),
    .library(
      name: "BoxListFeature",
      targets: ["BoxListFeature"]),
    .library(
      name: "BoxRowFeature",
      targets: ["BoxRowFeature"]),
    .library(
      name: "Database",
      targets: ["Database"]),
    .library(
      name: "Models",
      targets: ["Models"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.10.1"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(name: "AppFeature", dependencies: [
      "Models",
      "Database",
      "BoxListFeature",
      .SCA,
    ]),
    .target(name: "BoxListFeature", dependencies: [
      "Models",
      "Database",
      "BoxRowFeature",
      .SCA,
    ]),
    .target(name: "BoxRowFeature", dependencies: [
      "Models",
      "Database",
      .SCA,
    ]),
    .target(
      name: "Database",
      dependencies: [
        "Models",
        .SCA,
      ]),
    .target(
      name: "Models"),
    .testTarget(
      name: "MindBoxPackageTests",
      dependencies: ["Models", "Database"]),
  ])

extension Target.Dependency {
  static let SCA: Target.Dependency = .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
}

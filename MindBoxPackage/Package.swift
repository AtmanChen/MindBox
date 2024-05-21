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
//    .library(
//      name: "Database",
//      targets: ["Database"]),
    .library(
      name: "Models",
      targets: ["Models"]),
    .library(
      name: "Utils",
      targets: ["Utils"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.10.1"),
    .package(url: "https://github.com/pointfreeco/swift-tagged.git", from: "0.10.0")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(name: "AppFeature", dependencies: [
      "Models",
//      "Database",
      "BoxListFeature",
      "Utils",
      .SCA,
    ]),
    .target(name: "BoxListFeature", dependencies: [
      "Models",
//      "Database",
      "BoxRowFeature",
      "Utils",
      .SCA,
    ]),
    .target(name: "BoxRowFeature", dependencies: [
      "Models",
//      "Database",
      "Utils",
      .SCA,
    ]),
    .target(
      name: "Database",
      dependencies: [
        "Models",
        .SCA,
      ]),
    .target(
      name: "Models",
      dependencies: [
        .SCA,
        .TAGGED,
      ]
    ),
    .target(
      name: "Utils",
      dependencies: [
      ]
    ),
    .testTarget(
      name: "MindBoxPackageTests",
      dependencies: ["Models", "Database"]),
  ]
)

extension Target.Dependency {
  static let SCA: Target.Dependency = .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
  static let TAGGED: Target.Dependency = .product(name: "Tagged", package: "swift-tagged")
}

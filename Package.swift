// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Pimiento",
    dependencies: [
        // Swift wrapper for ImageMagick (MagickWand) for Linux and MacOS
        .package(url: "https://github.com/naithar/MagickWand.git", from: "0.5.1"),

        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.1.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: [
          "FluentSQLite", "MagickWand", "Vapor"
        ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)


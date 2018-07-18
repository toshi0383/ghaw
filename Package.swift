// swift-tools-version:4.0
// Managed by ice

import PackageDescription

let package = Package(
    name: "ghaw",
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift", from: "4.2.0"),
        .package(url: "https://github.com/JohnSundell/ShellOut", from: "2.1.0"),
    ],
    targets: [
        .target(name: "ghaw", dependencies: ["RxSwift", "RxCocoa", "ShellOut"]),
    ]
)
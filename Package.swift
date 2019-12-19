// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "ghaw",
    products: [
        .executable(name: "ghaw", targets: ["ghaw"]),
    ],
    dependencies: [
        .package(url: "https://github.com/toshi0383/CoreCLI", .upToNextMajor(from: "0.1.10")),
        .package(url: "https://github.com/JohnSundell/ShellOut", .upToNextMajor(from: "2.2.0")),
        .package(url: "https://github.com/ReactiveX/RxSwift", .upToNextMajor(from: "5.0.0")),
    ],
    targets: [
        .target(name: "ghaw", dependencies: ["RxSwift", "RxCocoa", "ShellOut", "CoreCLI"]),
    ]
)

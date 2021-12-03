// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "ApartsFinder",
    platforms: [.macOS(.v12)],
    dependencies: [
        .package(url: "https://github.com/pvieito/PythonKit.git", from: "0.1.1")
    ],
    targets: [
        .executableTarget(
            name: "ApartsFinder",
            dependencies: ["Core"]),
        .target(name: "Core",
                dependencies: ["PythonKit"]),
        .testTarget(
            name: "ApartsFinderTests",
            dependencies: ["Core"]),
    ]
)

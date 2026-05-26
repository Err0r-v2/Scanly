// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ScanlyDeploy",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "ScanlyDeploy",
            path: "Sources/ScanlyDeploy",
            resources: [
                .copy("Resources")
            ]
        )
    ]
)

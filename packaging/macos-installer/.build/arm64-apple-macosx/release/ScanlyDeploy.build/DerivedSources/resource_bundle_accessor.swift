import Foundation

extension Foundation.Bundle {
    static nonisolated let module: Bundle = {
        let mainPath = Bundle.main.bundleURL.appendingPathComponent("ScanlyDeploy_ScanlyDeploy.bundle").path
        let buildPath = "/Users/stan/Desktop/Scanly/packaging/macos-installer/.build/arm64-apple-macosx/release/ScanlyDeploy_ScanlyDeploy.bundle"

        let preferredBundle = Bundle(path: mainPath)

        guard let bundle = preferredBundle ?? Bundle(path: buildPath) else {
            // Users can write a function called fatalError themselves, we should be resilient against that.
            Swift.fatalError("could not load resource bundle: from \(mainPath) or \(buildPath)")
        }

        return bundle
    }()
}
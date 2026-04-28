import Foundation

enum AppRegistryError: Error {
    case notAppBundle
    case invalidBundle
    case missingBundleId
}

struct AppRegistry {
    func trackedApp(from appURL: URL) throws -> TrackedApp {
        guard appURL.pathExtension.lowercased() == "app" else {
            throw AppRegistryError.notAppBundle
        }
        guard let bundle = Bundle(url: appURL) else {
            throw AppRegistryError.invalidBundle
        }
        guard let bundleId = bundle.bundleIdentifier else {
            throw AppRegistryError.missingBundleId
        }

        let displayName = (bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String)
            ?? (bundle.object(forInfoDictionaryKey: "CFBundleName") as? String)
            ?? appURL.deletingPathExtension().lastPathComponent

        return TrackedApp(displayName: displayName, bundleId: bundleId, appPath: appURL.path)
    }
}

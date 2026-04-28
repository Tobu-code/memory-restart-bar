import AppKit
import Foundation

enum RestartError: Error {
    case terminateTimeout
    case launchFailed
}

final class RestartService {
    func restart(app: TrackedApp, timeout: TimeInterval = 6) async -> Result<Void, RestartError> {
        if let runningApp = NSRunningApplication.runningApplications(withBundleIdentifier: app.bundleId).first {
            let terminateTriggered = runningApp.terminate()
            if !terminateTriggered {
                return .failure(.terminateTimeout)
            }
            let terminated = await waitForTermination(bundleId: app.bundleId, timeout: timeout)
            if !terminated {
                return .failure(.terminateTimeout)
            }
        }

        guard await launch(app: app) else {
            return .failure(.launchFailed)
        }
        return .success(())
    }

    private func launch(app: TrackedApp) async -> Bool {
        let appURL = URL(fileURLWithPath: app.appPath)
        if FileManager.default.fileExists(atPath: appURL.path) {
            return await openApplication(at: appURL)
        }

        guard let resolvedURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: app.bundleId) else {
            return false
        }
        return await openApplication(at: resolvedURL)
    }

    private func openApplication(at url: URL) async -> Bool {
        await withCheckedContinuation { continuation in
            NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration()) { _, error in
                continuation.resume(returning: error == nil)
            }
        }
    }

    private func waitForTermination(bundleId: String, timeout: TimeInterval) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if NSRunningApplication.runningApplications(withBundleIdentifier: bundleId).isEmpty {
                return true
            }
            try? await Task.sleep(nanoseconds: 200_000_000)
        }
        return NSRunningApplication.runningApplications(withBundleIdentifier: bundleId).isEmpty
    }
}

import AppKit
import UniformTypeIdentifiers

final class StatusBarController: NSObject {
    private let statusItem: NSStatusItem
    private let menu = NSMenu()
    private let appStore = AppStore()
    private let appRegistry = AppRegistry()
    private var trackedApps: [TrackedApp] = []
    private var statusText = "Ready"

    override init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()
        trackedApps = appStore.loadApps()
        configureStatusItem()
        rebuildMenu()
    }

    private func configureStatusItem() {
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "arrow.triangle.2.circlepath", accessibilityDescription: "MemoryRestartBar")
            button.imagePosition = .imageOnly
        }
        statusItem.menu = menu
    }

    private func rebuildMenu() {
        menu.removeAllItems()

        let titleItem = NSMenuItem(title: "MemoryRestartBar", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)

        let statusItem = NSMenuItem(title: statusText, action: nil, keyEquivalent: "")
        statusItem.isEnabled = false
        menu.addItem(statusItem)

        menu.addItem(.separator())

        let addItem = NSMenuItem(title: "Add Application...", action: #selector(handleAddApplication), keyEquivalent: "")
        addItem.target = self
        menu.addItem(addItem)

        let restartAllItem = NSMenuItem(title: "Restart All", action: #selector(handleRestartAll), keyEquivalent: "")
        restartAllItem.target = self
        restartAllItem.isEnabled = !trackedApps.isEmpty
        menu.addItem(restartAllItem)

        menu.addItem(.separator())

        if trackedApps.isEmpty {
            let emptyItem = NSMenuItem(title: "No applications added yet", action: nil, keyEquivalent: "")
            emptyItem.isEnabled = false
            menu.addItem(emptyItem)
        } else {
            for app in trackedApps {
                let appItem = NSMenuItem(title: app.displayName, action: #selector(handleTrackedAppClicked(_:)), keyEquivalent: "")
                appItem.target = self
                appItem.representedObject = app.bundleId
                menu.addItem(appItem)
            }
        }

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(handleQuit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
    }

    @objc
    private func handleAddApplication() {
        NSApp.activate(ignoringOtherApps: true)
        let panel = NSOpenPanel()
        panel.title = "Select an application"
        panel.allowedContentTypes = [.applicationBundle]
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.treatsFilePackagesAsDirectories = false
        panel.directoryURL = URL(fileURLWithPath: "/Applications", isDirectory: true)

        guard panel.runModal() == .OK, let selectedURL = panel.url else {
            statusText = "Selection cancelled"
            rebuildMenuAndPresent()
            return
        }

        do {
            let trackedApp = try appRegistry.trackedApp(from: selectedURL)
            if trackedApps.contains(where: { $0.bundleId == trackedApp.bundleId }) {
                statusText = "Already added: \(trackedApp.displayName)"
                rebuildMenuAndPresent()
                showAlert(message: "应用已存在：\(trackedApp.displayName)")
                return
            }
            trackedApps.append(trackedApp)
            appStore.saveApps(trackedApps)
            statusText = "Added: \(trackedApp.displayName)"
            rebuildMenuAndPresent()
        } catch AppRegistryError.notAppBundle {
            statusText = "Please select a .app"
            rebuildMenuAndPresent()
            showAlert(message: "请选择 .app 应用")
        } catch AppRegistryError.missingBundleId {
            statusText = "Invalid app: bundle id missing"
            rebuildMenuAndPresent()
            showAlert(message: "应用无效：缺少 bundle id")
        } catch {
            statusText = "Failed to add app"
            rebuildMenuAndPresent()
            showAlert(message: "添加失败，请重试")
        }
    }

    @objc
    private func handleRestartAll() {
        statusText = "Restart All is not implemented yet"
        rebuildMenu()
    }

    @objc
    private func handleTrackedAppClicked(_ sender: NSMenuItem) {
        guard let bundleId = sender.representedObject as? String,
              let app = trackedApps.first(where: { $0.bundleId == bundleId }) else {
            return
        }
        statusText = "Restart pending: \(app.displayName)"
        rebuildMenu()
    }

    @objc
    private func handleQuit() {
        NSApp.terminate(nil)
    }

    private func rebuildMenuAndPresent() {
        rebuildMenu()
        guard let button = statusItem.button else { return }
        DispatchQueue.main.async {
            button.performClick(nil)
        }
    }

    private func showAlert(message: String) {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.messageText = message
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

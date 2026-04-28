import XCTest
@testable import MemoryRestartBar

final class AppStoreTests: XCTestCase {
    func test_loadApps_returnsEmpty_whenNoDataExists() {
        let suiteName = "AppStoreTests.Empty.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let store = AppStore(defaults: defaults)

        XCTAssertEqual(store.loadApps(), [])
    }

    func test_saveApps_thenLoadApps_roundTrip() {
        let suiteName = "AppStoreTests.RoundTrip.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let store = AppStore(defaults: defaults)
        let app = TrackedApp(displayName: "Ghostty", bundleId: "com.example.ghostty", appPath: "/Applications/Ghostty.app")

        store.saveApps([app])

        XCTAssertEqual(store.loadApps(), [app])
    }
}

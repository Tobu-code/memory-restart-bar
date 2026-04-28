import XCTest
@testable import MemoryRestartBar

final class AppRegistryTests: XCTestCase {
    func test_trackedApp_throwsNotAppBundle_forNonAppURL() {
        let registry = AppRegistry()
        let url = URL(fileURLWithPath: "/tmp/not-an-app.txt")

        XCTAssertThrowsError(try registry.trackedApp(from: url)) { error in
            guard case AppRegistryError.notAppBundle = error else {
                return XCTFail("Expected notAppBundle")
            }
        }
    }
}

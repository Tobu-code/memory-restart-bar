import Foundation

struct TrackedApp: Codable, Equatable {
    let id: UUID
    let displayName: String
    let bundleId: String
    let appPath: String

    init(id: UUID = UUID(), displayName: String, bundleId: String, appPath: String) {
        self.id = id
        self.displayName = displayName
        self.bundleId = bundleId
        self.appPath = appPath
    }
}

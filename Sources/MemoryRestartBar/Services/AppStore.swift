import Foundation

final class AppStore {
    private let defaults: UserDefaults
    private let storageKey = "trackedApps"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadApps() -> [TrackedApp] {
        guard let data = defaults.data(forKey: storageKey) else {
            return []
        }
        do {
            return try decoder.decode([TrackedApp].self, from: data)
        } catch {
            return []
        }
    }

    func saveApps(_ apps: [TrackedApp]) {
        guard let data = try? encoder.encode(apps) else {
            return
        }
        defaults.set(data, forKey: storageKey)
    }
}

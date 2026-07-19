import Foundation

/// Process launch arguments recognized by the app under UI tests.
///
/// UI tests append these via `XCUIApplication.launchForUITesting(...)`.
enum UITestLaunchArguments {
    /// Master flag: app is running under UI automation.
    static let uiTesting = "-ui-testing"
    /// Request an empty persistence surface (no seeded catalog / user data).
    static let emptyStore = "-ui-testing-empty"
    /// Request a seeded persistence surface (catalog + sample user data when available).
    static let seededStore = "-ui-testing-seeded"

    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains(uiTesting)
    }

    static var prefersEmptyStore: Bool {
        isUITesting && ProcessInfo.processInfo.arguments.contains(emptyStore)
    }

    static var prefersSeededStore: Bool {
        isUITesting && ProcessInfo.processInfo.arguments.contains(seededStore)
    }

    /// Accessibility identifier for the active launch data mode (for UI assertions).
    static var storeModeAccessibilityIdentifier: String {
        if prefersEmptyStore {
            return "app.store-mode.empty"
        }
        if prefersSeededStore {
            return "app.store-mode.seeded"
        }
        return "app.store-mode.default"
    }
}

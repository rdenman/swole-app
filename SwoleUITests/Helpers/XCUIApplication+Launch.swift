import XCTest

extension XCUIApplication {
    enum UITestStoreMode {
        case empty
        case seeded
    }

    /// Launches the app with UI-testing launch arguments.
    ///
    /// - Parameter storeMode: Optional empty/seeded preference. Omit for the default store path.
    func launchForUITesting(storeMode: UITestStoreMode? = nil) {
        var arguments = ["-ui-testing"]
        switch storeMode {
        case .empty:
            arguments.append("-ui-testing-empty")
        case .seeded:
            arguments.append("-ui-testing-seeded")
        case nil:
            break
        }
        launchArguments = arguments
        launch()
    }
}

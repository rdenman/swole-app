import XCTest

final class LaunchArgumentUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchWithEmptyStoreArgument() {
        let app = XCUIApplication()
        app.launchForUITesting(storeMode: .empty)

        XCTAssertTrue(app.staticTexts["Swole"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["app.store-mode.empty"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testLaunchWithSeededStoreArgument() {
        let app = XCUIApplication()
        app.launchForUITesting(storeMode: .seeded)

        XCTAssertTrue(app.staticTexts["Swole"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["app.store-mode.seeded"].waitForExistence(timeout: 2))
    }
}

import Testing
@testable import Swole

struct SmokeTests {
    @Test func appModuleLoads() {
        let view = ContentView()
        #expect(String(describing: type(of: view)) == "ContentView")
    }
}

@testable import Swole
import Testing

struct SmokeTests {
    @Test func appModuleLoads() {
        let view = ContentView()
        #expect(String(describing: type(of: view)) == "ContentView")
    }
}

@testable import Swole
import Testing

@MainActor
struct SampleSnapshotTests {
    @Test func contentViewDesignSystemVariants() {
        DesignSystemSnapshots.assertComponent(ContentView(), named: "ContentView")
    }
}

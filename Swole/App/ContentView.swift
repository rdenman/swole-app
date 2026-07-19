import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Swole")
            Text(storeModeLabel)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier(UITestLaunchArguments.storeModeAccessibilityIdentifier)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("app.root")
    }

    private var storeModeLabel: String {
        if UITestLaunchArguments.prefersEmptyStore {
            return "Empty store"
        }
        if UITestLaunchArguments.prefersSeededStore {
            return "Seeded store"
        }
        return "Default store"
    }
}

#Preview {
    ContentView()
}

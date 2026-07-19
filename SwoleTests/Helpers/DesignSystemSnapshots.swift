import SnapshotTesting
import SwiftUI
import UIKit

/// Snapshot conventions for design-system components (and simple SwiftUI surfaces).
///
/// Each call records/asserts three variants so light/dark and Dynamic Type stay covered:
/// - `*-light` — light mode, default dynamic type
/// - `*-dark` — dark mode, default dynamic type
/// - `*-ax3` — light mode, accessibility-3 dynamic type
enum DesignSystemSnapshots {
    /// Fixed canvas width for a single component (not a full device chrome).
    static let componentWidth: CGFloat = 390
    /// Fixed canvas height for a single component.
    static let componentHeight: CGFloat = 200

    private struct Variant {
        let suffix: String
        let interfaceStyle: UIUserInterfaceStyle
        let contentSizeCategory: UIContentSizeCategory
    }

    @MainActor
    static func assertComponent(
        _ view: some View,
        named name: String,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line
    ) {
        let layout = SwiftUISnapshotLayout.fixed(width: componentWidth, height: componentHeight)
        let variants = [
            Variant(suffix: "light", interfaceStyle: .light, contentSizeCategory: .large),
            Variant(suffix: "dark", interfaceStyle: .dark, contentSizeCategory: .large),
            Variant(
                suffix: "ax3",
                interfaceStyle: .light,
                contentSizeCategory: .accessibilityExtraExtraExtraLarge
            ),
        ]

        for variant in variants {
            let traits = UITraitCollection { mutableTraits in
                mutableTraits.userInterfaceStyle = variant.interfaceStyle
                mutableTraits.preferredContentSizeCategory = variant.contentSizeCategory
            }
            let configured = view
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))

            assertSnapshot(
                of: configured,
                as: .image(layout: layout, traits: traits),
                named: "\(name)-\(variant.suffix)",
                file: file,
                testName: testName,
                line: line
            )
        }
    }
}

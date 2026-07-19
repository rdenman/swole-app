import Foundation
import SwiftData

/// Minimal `@Model` used to exercise the testing harness until S09 domain models land.
@Model
final class SampleRecord {
    var name: String
    var createdAt: Date

    init(name: String, createdAt: Date = .init(timeIntervalSince1970: 0)) {
        self.name = name
        self.createdAt = createdAt
    }
}

enum SampleRecordFixtures {
    static let referenceDate = Date(timeIntervalSince1970: 1_700_000_000)

    static func make(
        name: String = "Bench Press",
        createdAt: Date = referenceDate
    ) -> SampleRecord {
        SampleRecord(name: name, createdAt: createdAt)
    }

    static func makeList(count: Int = 3, namePrefix: String = "Exercise") -> [SampleRecord] {
        (0 ..< count).map { index in
            make(name: "\(namePrefix) \(index + 1)", createdAt: referenceDate.addingTimeInterval(TimeInterval(index)))
        }
    }
}

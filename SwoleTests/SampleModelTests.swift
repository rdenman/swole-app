import SwiftData
import Testing

@MainActor
struct SampleModelTests {
    @Test func insertAndFetchSampleRecord() throws {
        // given
        let container = try InMemoryModelContainerFactory.make(for: [SampleRecord.self])
        let context = ModelContext(container)

        // when
        context.insert(SampleRecordFixtures.make())
        try context.save()

        // then
        let records = try context.fetch(FetchDescriptor<SampleRecord>())
        #expect(records.count == 1)
        #expect(records.first?.name == "Bench Press")
        #expect(records.first?.createdAt == SampleRecordFixtures.referenceDate)
    }

    @Test func fixtureBuilderProducesDistinctNames() throws {
        // given
        let container = try InMemoryModelContainerFactory.make(for: [SampleRecord.self])
        let context = ModelContext(container)

        // when
        for record in SampleRecordFixtures.makeList(count: 3) {
            context.insert(record)
        }
        try context.save()

        // then
        let names = try context.fetch(FetchDescriptor<SampleRecord>()).map(\.name).sorted()
        #expect(names == ["Exercise 1", "Exercise 2", "Exercise 3"])
    }
}

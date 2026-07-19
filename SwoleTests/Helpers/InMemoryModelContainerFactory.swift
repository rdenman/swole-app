import SwiftData

/// Builds disposable in-memory SwiftData containers for unit tests.
enum InMemoryModelContainerFactory {
    /// Creates an in-memory `ModelContainer` for the given model types.
    @MainActor
    static func make(for types: [any PersistentModel.Type]) throws -> ModelContainer {
        let schema = Schema(types)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}

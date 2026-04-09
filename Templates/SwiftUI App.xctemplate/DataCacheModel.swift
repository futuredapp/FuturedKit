//  ___FILEHEADER___

nonisolated struct DataCacheModel: Equatable, Sendable {
    // Cached properties
    var exampleItem: ExampleItem?
}

extension DataCacheModel {
    struct ExampleItem: Equatable, Sendable, Identifiable {
        let id: String
        var title: String
    }
}

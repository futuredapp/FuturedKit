//  ___FILEHEADER___

nonisolated struct DataCacheModel: Equatable, Sendable {
    // Cached properties
    var exampleItem: ExampleItem?
}

nonisolated struct ExampleItem: Equatable, Sendable, Identifiable {
    let id: String
    var title: String
}

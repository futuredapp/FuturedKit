//  ___FILEHEADER___

@dynamicMemberLookup
struct ExampleCacheProjection: CacheProjection {
    typealias CacheModel = DataCacheModel
    typealias ID = Void

    var state: ComponentState
    var data: ExampleData

    subscript<T>(dynamicMember keyPath: WritableKeyPath<ExampleData, T>) -> T {
        get { data[keyPath: keyPath] }
        set { data[keyPath: keyPath] = newValue }
    }

    static func empty(state: ComponentState) -> Self {
        Self(state: state, data: .mock)
    }

    static func data(from cache: DataCacheModel) -> Self? {
        guard let item = cache.exampleItem else {
            return nil
        }
        return Self(
            state: .ready,
            data: ExampleData(title: item.title)
        )
    }
}

struct ExampleData: Equatable, Mockable {
    var title: String

    static var mock: Self {
        Self(title: "Loading...")
    }
}

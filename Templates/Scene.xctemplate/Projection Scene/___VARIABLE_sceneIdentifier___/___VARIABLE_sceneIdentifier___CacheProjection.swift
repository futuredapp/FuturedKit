//  ___FILEHEADER___

@dynamicMemberLookup
struct ___VARIABLE_sceneIdentifier___CacheProjection: CacheProjection {
    typealias CacheModel = DataCacheModel
    typealias ID = Void

    var state: ComponentState
    var data: ___VARIABLE_sceneIdentifier___Data

    subscript<T>(dynamicMember keyPath: WritableKeyPath<___VARIABLE_sceneIdentifier___Data, T>) -> T {
        get { data[keyPath: keyPath] }
        set { data[keyPath: keyPath] = newValue }
    }

    static func empty(state: ComponentState) -> Self {
        Self(state: state, data: .mock)
    }

    static func data(from cache: DataCacheModel) -> Self? {
        // TODO: Map cache data to projection
        nil
    }
}

struct ___VARIABLE_sceneIdentifier___Data: Equatable, Mockable {
    // TODO: Add data properties

    static var mock: Self {
        Self()
    }
}

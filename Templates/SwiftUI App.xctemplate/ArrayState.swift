//  ___FILEHEADER___

/// State wrapper for a collection of items.
///
/// **Rendering:** prefer converting `ArrayState` to `ItemState` via a
/// computed property on your `CacheProjection` data struct, then render
/// with `ItemStateView`. Direct array rendering tends to leak filtering
/// and sorting logic into views.
enum ArrayState<Value: Equatable & Mockable>: Equatable {
    case populated(MockableArray<Value>)
    case loading
    case error(StateInfoConfig)

    var values: [Value]? {
        if case let .populated(array) = self {
            return array.items
        }
        return nil
    }

    var errorConfig: StateInfoConfig? {
        if case let .error(config) = self {
            return config
        }
        return nil
    }
}

struct MockableArray<Element: Equatable & Mockable>: Equatable, Mockable {
    let items: [Element]

    static var mock: Self {
        .init(items: [Element.mock])
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.items == rhs.items
    }
}

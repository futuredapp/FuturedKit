//  ___FILEHEADER___

struct MockableArray<Element: Equatable & Mockable>: Equatable, Mockable {
    let items: [Element]

    static var mock: Self {
        .init(items: [Element.mock])
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.items == rhs.items
    }
}

enum ArrayState<Value: Equatable & Mockable>: Equatable {
    case populated(MockableArray<Value>)
    case loading
    case error(ErrorViewConfig)

    var values: [Value]? {
        if case let .populated(array) = self {
            return array.items
        }
        return nil
    }

    var errorConfig: ErrorViewConfig? {
        if case let .error(config) = self {
            return config
        }
        return nil
    }
}

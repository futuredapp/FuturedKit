//  ___FILEHEADER___

/// State wrapper for a single data item inside a component.
///
/// There is no `.empty` case — `.populated` implies the data exists.
enum ItemState<Value: Mockable & Equatable>: Equatable {
    case populated(Value)
    case loading
    case error(StateInfoConfig)

    var value: Value? {
        if case let .populated(value) = self {
            return value
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

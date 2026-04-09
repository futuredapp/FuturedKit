//  ___FILEHEADER___

enum ItemState<Value: Mockable & Equatable>: Equatable {
    case populated(Value)
    case loading
    case error(ErrorViewConfig)

    var value: Value? {
        if case let .populated(value) = self {
            return value
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

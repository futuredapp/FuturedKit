//  ___FILEHEADER___

enum ComponentState: Equatable {
    case ready
    case loading
    case empty
    case error(ErrorViewConfig)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var isError: Bool {
        if case .error = self { return true }
        return false
    }

    var errorConfig: ErrorViewConfig? {
        if case let .error(config) = self { return config }
        return nil
    }
}

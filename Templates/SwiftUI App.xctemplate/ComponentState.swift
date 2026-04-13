//  ___FILEHEADER___

/// Screen/component-level lifecycle state.
///
/// `.empty` and `.error` require a `StateInfoConfig` so that every
/// non-populated state is explicitly designed — no silent placeholders.
enum ComponentState: Equatable {
    case ready
    case loading
    case empty(StateInfoConfig)
    case error(StateInfoConfig)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var isError: Bool {
        if case .error = self { return true }
        return false
    }

    var infoConfig: StateInfoConfig? {
        switch self {
        case let .empty(config), let .error(config):
            return config
        case .ready, .loading:
            return nil
        }
    }
}

//  ___FILEHEADER___

import SwiftUI

struct ItemStateView<
    Value: Mockable & Equatable,
    PopulatedView: View,
    LoadingView: View,
    ErrorView: View
>: View {
    let state: ItemState<Value>
    let populatedView: (Value) -> PopulatedView
    let loadingView: (Value) -> LoadingView
    let errorView: (ErrorViewConfig) -> ErrorView

    init(
        state: ItemState<Value>,
        @ViewBuilder populatedView: @escaping (Value) -> PopulatedView,
        @ViewBuilder loadingView: @escaping (Value) -> LoadingView,
        @ViewBuilder errorView: @escaping (ErrorViewConfig) -> ErrorView
    ) {
        self.state = state
        self.populatedView = populatedView
        self.loadingView = loadingView
        self.errorView = errorView
    }

    var body: some View {
        switch state {
        case let .populated(value):
            populatedView(value)
        case .loading:
            loadingView(Value.mock)
                .redacted(reason: LoadingView.self == PopulatedView.self ? [.placeholder] : [])
        case let .error(config):
            errorView(config)
        }
    }
}

extension ItemStateView where LoadingView == PopulatedView {
    init(
        state: ItemState<Value>,
        @ViewBuilder populatedView: @escaping (Value) -> PopulatedView,
        @ViewBuilder errorView: @escaping (ErrorViewConfig) -> ErrorView
    ) {
        self.state = state
        self.populatedView = populatedView
        self.loadingView = populatedView
        self.errorView = errorView
    }
}

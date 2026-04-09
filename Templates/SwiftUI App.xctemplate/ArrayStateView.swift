//  ___FILEHEADER___

import SwiftUI

struct ArrayStateView<
    Value: Equatable & Mockable,
    PopulatedView: View,
    LoadingView: View,
    ErrorView: View
>: View {
    let state: ArrayState<Value>
    let populatedView: ([Value]) -> PopulatedView
    let loadingView: ([Value]) -> LoadingView
    let errorView: (ErrorViewConfig) -> ErrorView

    init(
        state: ArrayState<Value>,
        @ViewBuilder populatedView: @escaping ([Value]) -> PopulatedView,
        @ViewBuilder loadingView: @escaping ([Value]) -> LoadingView,
        @ViewBuilder errorView: @escaping (ErrorViewConfig) -> ErrorView
    ) {
        self.state = state
        self.populatedView = populatedView
        self.loadingView = loadingView
        self.errorView = errorView
    }

    var body: some View {
        switch state {
        case let .populated(array):
            populatedView(array.items)
        case .loading:
            loadingView([Value.mock])
                .redacted(reason: LoadingView.self == PopulatedView.self ? [.placeholder] : [])
        case let .error(config):
            errorView(config)
        }
    }
}

extension ArrayStateView where LoadingView == PopulatedView {
    init(
        state: ArrayState<Value>,
        @ViewBuilder populatedView: @escaping ([Value]) -> PopulatedView,
        @ViewBuilder errorView: @escaping (ErrorViewConfig) -> ErrorView
    ) {
        self.state = state
        self.populatedView = populatedView
        self.loadingView = populatedView
        self.errorView = errorView
    }
}

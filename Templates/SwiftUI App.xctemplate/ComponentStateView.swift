//  ___FILEHEADER___

import SwiftUI

struct ComponentStateView<
    PopulatedView: View,
    EmptyView: View,
    LoadingView: View,
    ErrorView: View
>: View {
    let state: ComponentState
    let populatedView: () -> PopulatedView
    let emptyView: () -> EmptyView
    let loadingView: () -> LoadingView
    let errorView: (ErrorViewConfig) -> ErrorView

    init(
        state: ComponentState,
        @ViewBuilder populatedView: @escaping () -> PopulatedView,
        @ViewBuilder emptyView: @escaping () -> EmptyView,
        @ViewBuilder loadingView: @escaping () -> LoadingView,
        @ViewBuilder errorView: @escaping (ErrorViewConfig) -> ErrorView
    ) {
        self.state = state
        self.populatedView = populatedView
        self.emptyView = emptyView
        self.loadingView = loadingView
        self.errorView = errorView
    }

    var body: some View {
        switch state {
        case .ready:
            populatedView()
        case .loading:
            loadingView()
                .redacted(reason: LoadingView.self == PopulatedView.self ? [.placeholder] : [])
        case .empty:
            emptyView()
        case let .error(config):
            errorView(config)
        }
    }
}

extension ComponentStateView where LoadingView == PopulatedView {
    init(
        state: ComponentState,
        @ViewBuilder populatedView: @escaping () -> PopulatedView,
        @ViewBuilder emptyView: @escaping () -> EmptyView,
        @ViewBuilder errorView: @escaping (ErrorViewConfig) -> ErrorView
    ) {
        self.state = state
        self.populatedView = populatedView
        self.emptyView = emptyView
        self.loadingView = populatedView
        self.errorView = errorView
    }
}

//  ___FILEHEADER___

import SwiftUI

/// Renders an `ItemState<Value>`. Used inline (inside a populated
/// component) for a single piece of data with its own loading/error state.
///
/// The error view receives a `StateInfoConfig` so inline errors can
/// render differently from full-screen component errors.
struct ItemStateView<
    Value: Mockable & Equatable,
    PopulatedView: View,
    LoadingView: View,
    ErrorView: View
>: View {
    private let state: ItemState<Value>
    private let populatedView: (Value) -> PopulatedView
    private let loadingView: (Value) -> LoadingView
    private let errorView: (StateInfoConfig) -> ErrorView

    init(
        state: ItemState<Value>,
        @ViewBuilder populatedView: @escaping (Value) -> PopulatedView,
        @ViewBuilder loadingView: @escaping (Value) -> LoadingView,
        @ViewBuilder errorView: @escaping (StateInfoConfig) -> ErrorView
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
        @ViewBuilder errorView: @escaping (StateInfoConfig) -> ErrorView
    ) {
        self.state = state
        self.populatedView = populatedView
        self.loadingView = populatedView
        self.errorView = errorView
    }
}

extension ItemStateView where ErrorView == StateInfoView {
    /// Defaults the error view to a full `StateInfoView`. Use the other
    /// initializers when you need a custom inline error layout.
    init(
        state: ItemState<Value>,
        @ViewBuilder populatedView: @escaping (Value) -> PopulatedView,
        @ViewBuilder loadingView: @escaping (Value) -> LoadingView
    ) {
        self.state = state
        self.populatedView = populatedView
        self.loadingView = loadingView
        self.errorView = { StateInfoView(config: $0) }
    }
}

extension ItemStateView where LoadingView == PopulatedView, ErrorView == StateInfoView {
    /// Defaults both the loading view (reuses populated with `.redacted`)
    /// and the error view (`StateInfoView`). Minimal call site.
    init(
        state: ItemState<Value>,
        @ViewBuilder populatedView: @escaping (Value) -> PopulatedView
    ) {
        self.state = state
        self.populatedView = populatedView
        self.loadingView = populatedView
        self.errorView = { StateInfoView(config: $0) }
    }
}

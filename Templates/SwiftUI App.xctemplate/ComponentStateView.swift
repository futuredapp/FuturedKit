//  ___FILEHEADER___

import SwiftUI

/// Renders a `ComponentState` lifecycle.
///
/// The `.empty` and `.error` cases carry a `StateInfoConfig`, which by
/// default is rendered via `StateInfoView`. Callers can provide custom
/// empty/error view builders when a screen needs a bespoke layout.
///
/// When `LoadingView == PopulatedView`, the loading state reuses the
/// populated view with `.redacted(reason: .placeholder)` applied.
struct ComponentStateView<
    PopulatedView: View,
    LoadingView: View,
    EmptyView: View,
    ErrorView: View
>: View {
    private let state: ComponentState
    private let populatedView: () -> PopulatedView
    private let loadingView: () -> LoadingView
    private let emptyView: (StateInfoConfig) -> EmptyView
    private let errorView: (StateInfoConfig) -> ErrorView

    init(
        state: ComponentState,
        @ViewBuilder populatedView: @escaping () -> PopulatedView,
        @ViewBuilder loadingView: @escaping () -> LoadingView,
        @ViewBuilder emptyView: @escaping (StateInfoConfig) -> EmptyView,
        @ViewBuilder errorView: @escaping (StateInfoConfig) -> ErrorView
    ) {
        self.state = state
        self.populatedView = populatedView
        self.loadingView = loadingView
        self.emptyView = emptyView
        self.errorView = errorView
    }

    var body: some View {
        switch state {
        case .ready:
            populatedView()
        case .loading:
            loadingView()
                .redacted(reason: LoadingView.self == PopulatedView.self ? [.placeholder] : [])
        case let .empty(config):
            emptyView(config)
        case let .error(config):
            errorView(config)
        }
    }
}

// MARK: - Default empty/error via StateInfoView

extension ComponentStateView where EmptyView == StateInfoView, ErrorView == StateInfoView {
    /// Uses `StateInfoView` as the default renderer for both empty and
    /// error states. Most common call shape.
    init(
        state: ComponentState,
        @ViewBuilder populatedView: @escaping () -> PopulatedView,
        @ViewBuilder loadingView: @escaping () -> LoadingView
    ) {
        self.init(
            state: state,
            populatedView: populatedView,
            loadingView: loadingView,
            emptyView: { StateInfoView(config: $0) },
            errorView: { StateInfoView(config: $0) }
        )
    }
}

extension ComponentStateView where
    LoadingView == PopulatedView,
    EmptyView == StateInfoView,
    ErrorView == StateInfoView {
    /// Minimal call site. Loading reuses the populated view (with
    /// `.redacted(.placeholder)`); empty and error use `StateInfoView`.
    init(
        state: ComponentState,
        @ViewBuilder populatedView: @escaping () -> PopulatedView
    ) {
        self.init(
            state: state,
            populatedView: populatedView,
            loadingView: populatedView,
            emptyView: { StateInfoView(config: $0) },
            errorView: { StateInfoView(config: $0) }
        )
    }
}

// MARK: - Custom loading, default empty/error

extension ComponentStateView where LoadingView == PopulatedView {
    /// Loading reuses populated; empty and error fully custom.
    init(
        state: ComponentState,
        @ViewBuilder populatedView: @escaping () -> PopulatedView,
        @ViewBuilder emptyView: @escaping (StateInfoConfig) -> EmptyView,
        @ViewBuilder errorView: @escaping (StateInfoConfig) -> ErrorView
    ) {
        self.init(
            state: state,
            populatedView: populatedView,
            loadingView: populatedView,
            emptyView: emptyView,
            errorView: errorView
        )
    }
}

// MARK: - Customize only error (empty defaults to StateInfoView)

extension ComponentStateView where EmptyView == StateInfoView {
    /// Custom error view; empty stays as the default `StateInfoView`.
    init(
        state: ComponentState,
        @ViewBuilder populatedView: @escaping () -> PopulatedView,
        @ViewBuilder loadingView: @escaping () -> LoadingView,
        @ViewBuilder errorView: @escaping (StateInfoConfig) -> ErrorView
    ) {
        self.init(
            state: state,
            populatedView: populatedView,
            loadingView: loadingView,
            emptyView: { StateInfoView(config: $0) },
            errorView: errorView
        )
    }
}

extension ComponentStateView where LoadingView == PopulatedView, EmptyView == StateInfoView {
    /// Custom error view; loading reuses populated, empty defaults.
    init(
        state: ComponentState,
        @ViewBuilder populatedView: @escaping () -> PopulatedView,
        @ViewBuilder errorView: @escaping (StateInfoConfig) -> ErrorView
    ) {
        self.init(
            state: state,
            populatedView: populatedView,
            loadingView: populatedView,
            emptyView: { StateInfoView(config: $0) },
            errorView: errorView
        )
    }
}

// MARK: - Customize only empty (error defaults to StateInfoView)

extension ComponentStateView where ErrorView == StateInfoView {
    /// Custom empty view; error stays as the default `StateInfoView`.
    init(
        state: ComponentState,
        @ViewBuilder populatedView: @escaping () -> PopulatedView,
        @ViewBuilder loadingView: @escaping () -> LoadingView,
        @ViewBuilder emptyView: @escaping (StateInfoConfig) -> EmptyView
    ) {
        self.init(
            state: state,
            populatedView: populatedView,
            loadingView: loadingView,
            emptyView: emptyView,
            errorView: { StateInfoView(config: $0) }
        )
    }
}

extension ComponentStateView where LoadingView == PopulatedView, ErrorView == StateInfoView {
    /// Custom empty view; loading reuses populated, error defaults.
    init(
        state: ComponentState,
        @ViewBuilder populatedView: @escaping () -> PopulatedView,
        @ViewBuilder emptyView: @escaping (StateInfoConfig) -> EmptyView
    ) {
        self.init(
            state: state,
            populatedView: populatedView,
            loadingView: populatedView,
            emptyView: emptyView,
            errorView: { StateInfoView(config: $0) }
        )
    }
}

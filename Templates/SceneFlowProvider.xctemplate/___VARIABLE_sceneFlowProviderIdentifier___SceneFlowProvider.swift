//  ___FILEHEADER___

import EnumIdentable
import FuturedHelpers
import SwiftUI

protocol ___VARIABLE_sceneFlowProviderIdentifier___FlowDestination: CoordinatorSceneFlowDestination {
    static var destination: Self { get }
    static var end: Self { get }
}


final class ___VARIABLE_sceneFlowProviderIdentifier___SceneFlowProvider: CoordinatorSceneFlowProvider {
    let onNavigateToDestination: (Destination) -> Void
    let onPop: () -> Void
    let onPresentSheet: ((Destination) -> Void)? = nil
    let onDismissSheet: (() -> Void)? = nil
    let onPresentFullscreenCover: ((Destination) -> Void)? = nil
    let onDismissFullscreenCover: (() -> Void)? = nil
    let onPopToDestination: ((Destination?) -> Void)? = nil
    let onShowError: ((Error) -> Void)? = nil

    private let container: Container

    init(
        container: Container,
        onNavigateToDestination: @escaping (Destination) -> Void,
        onPop: @escaping () -> Void
    ) {
        self.container = container
        self.onNavigateToDestination = onNavigateToDestination
        self.onPop = onPop
    }

    static func rootView(with instance: ___VARIABLE_sceneFlowProviderIdentifier___SceneFlowProvider) -> some View {
        EmptyView()
    }

    func scene(for destination: Destination) -> some View {
        switch destination {
        case .destination:
            EmptyView()
        case .end:
            EmptyView()
        }
    }
}

extension ___VARIABLE_sceneFlowProviderIdentifier___SceneFlowProvider {
    @EnumIdentable
    enum Destination: ___VARIABLE_sceneFlowProviderIdentifier___FlowDestination {
        case destination
        case end
    }
}

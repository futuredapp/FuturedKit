//  ___FILEHEADER___

import EnumIdentable
import FuturedArchitecture
import FuturedHelpers
import SwiftUI

protocol ___VARIABLE_sceneFlowProviderIdentifier___FlowDestination: CoordinatorSceneFlowDestination {
    static var destination: Self { get }
    static var end: Self { get }
}


final class ___VARIABLE_sceneFlowProviderIdentifier___SceneFlowProvider: CoordinatorSceneFlowProvider {
    let navigateTo: (Destination) -> Void
    let pop: () -> Void
    let present: ((Destination, ModalCoverModel<Destination>.Style) -> Void)? = nil
    let dismissModal: (() -> Void)? = nil
    let onModalDismiss: (() -> Void)? = nil
    let popTo: ((Destination?) -> Void)? = nil

    private let container: Container

    init(
        container: Container,
        navigateTo: @escaping (Destination) -> Void,
        pop: @escaping () -> Void
    ) {
        self.container = container
        self.navigateTo = navigateTo
        self.pop = pop
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

//  ___FILEHEADER___

import EnumIdentable
import FuturedArchitecture
import Observation
import SwiftUI

@Observable
final class ___VARIABLE_flowCoordinatorIdentifier___FlowCoordinator: @MainActor NavigationStackCoordinator {
    private var container: Container

    var path: [Destination] = []
    var modalCover: ModalCoverModel<Destination>?

    init(container: Container) {
        self.container = container
    }

    static func rootView(with instance: ___VARIABLE_flowCoordinatorIdentifier___FlowCoordinator) -> some View {
        NavigationStackFlow(coordinator: instance) {
            EmptyView()
        }
    }

    @ViewBuilder
    func scene(for destination: Destination) -> some View {
        switch destination {
        case .destination:
            EmptyView()
        }
    }
}

extension ___VARIABLE_flowCoordinatorIdentifier___FlowCoordinator {
    @EnumIdentable
    nonisolated enum Destination {
        case destination
    }
}

//  ___FILEHEADER___

import EnumIdentable
import FuturedArchitecture
import Observation
import SwiftUI

@Observable
final class ExampleFlowCoordinator: @MainActor NavigationStackCoordinator {
    private var container: Container

    var path: [Destination] = []
    var modalCover: ModalCoverModel<Destination>?

    init(container: Container) {
        self.container = container
    }

    static func rootView(with instance: ExampleFlowCoordinator) -> some View {
        NavigationStackFlow(coordinator: instance) {
            ExampleComponent(
                model: ExampleComponentModel(
                    dataCache: instance.container.dataCache) { [weak instance] event in
                    switch event {
                    case .touchEvent:
                        instance?.navigate(to: .destination)
                    }
                }
            )
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

extension ExampleFlowCoordinator {
    @EnumIdentable
    nonisolated enum Destination {
        case destination
    }
}

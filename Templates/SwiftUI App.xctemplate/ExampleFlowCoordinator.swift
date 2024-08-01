//  ___FILEHEADER___

import EnumIdentifiersGenerator
import FuturedArchitecture
import SwiftUI

final class ExampleFlowCoordinator: NavigationStackCoordinator {
    private var container: Container

    @Published var path: [Destination] = []
    @Published var modalCover: ModalCoverModel<Destination>?

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
                        instance?.path.append(.destination)
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
    @EnumIdentifiersGenerator
    enum Destination: String, Hashable, Identifiable {
        case destination
    }
}

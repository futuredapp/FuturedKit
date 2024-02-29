//  ___FILEHEADER___

import FuturedArchitecture
import SwiftUI

final class BaseFlowCoordinator: NavigationStackCoordinator {
    private var container: ___PACKAGENAME:identifier___Container

    @Published var path: [Destination] = []
    @Published var sheet: Destination?
    @Published var alertModel: AlertModel?

    init(container: ___PACKAGENAME:identifier___Container) {
        self.container = container
    }

    static func rootView(with instance: BaseFlowCoordinator) -> some View {
        NavigationStackFlow(coordinator: instance) {
            BaseComponent(model: BaseComponentModel(
                dataCache: instance.container.dataCache,
                onEvent: { [weak instance] event in 
                    switch event {
                        case .touchEvent:
                            instance?.path.append(.destination)
                    }
                }
            ))
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

extension BaseFlowCoordinator {
    enum Destination: String, Hashable, Identifiable {
        case destination

        var id: String {
            rawValue
        }
    }
}

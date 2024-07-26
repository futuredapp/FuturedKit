//  ___FILEHEADER___

import FuturedArchitecture
import SwiftUI

final class ExampleFlowCoordinator: NavigationStackCoordinator {
    private var container: Container

    @Published var path: [Destination] = []
    @Published var sheet: Destination?
    @Published var fullscreenCover: Destination?
    @Published var alertModel: AlertModel?

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
                    case let .alert(title, message):
                        instance?.alertModel = .init(title: title, message: message)
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
    enum Destination: String, Hashable, Identifiable {
        case destination

        var id: String {
            rawValue
        }
    }
}

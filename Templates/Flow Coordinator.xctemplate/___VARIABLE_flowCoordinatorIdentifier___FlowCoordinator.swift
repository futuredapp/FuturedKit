//  ___FILEHEADER___

import FuturedArchitecture
import SwiftUI

final class ___VARIABLE_flowCoordinatorIdentifier___FlowCoordinator: NavigationStackCoordinator {
    private var container: Container

    @Published var path: [Destination] = []
    @Published var sheet: Destination?
    @Published var fullscreenCover: Destination?

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
    enum Destination: String, Hashable, Identifiable {
        case destination

        var id: String {
            rawValue
        }
    }
}

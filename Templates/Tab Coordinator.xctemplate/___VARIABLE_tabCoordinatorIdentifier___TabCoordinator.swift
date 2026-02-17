//  ___FILEHEADER___

import EnumIdentable
import FuturedArchitecture
import Observation
import SwiftUI

@Observable
final class ___VARIABLE_tabCoordinatorIdentifier___TabCoordinator: @MainActor TabCoordinator {
    nonisolated enum Tab {
        case firstTab
        case secondTab
    }

    private let container: Container

    var selectedTab: Tab
    var modalCover: ModalCoverModel<Destination>?

    init(container: Container, selectedTab: Tab) {
        self.container = container
        self.selectedTab = selectedTab
    }

    @ViewBuilder
    static func rootView(with instance: ___VARIABLE_tabCoordinatorIdentifier___TabCoordinator) -> some View {
        TabViewFlow(coordinator: instance) {
            Text("First Tab")
                .tabItem {
                    Text("First")
                }
                .tag(Tab.firstTab)

            Text("Second Tab")
                .tabItem {
                    Text("Second")
                }
                .tag(Tab.secondTab)
        }
    }

    func scene(for destination: Destination) -> some View {
        switch destination {
        case .destination:
            EmptyView()
        }
    }
}

extension ___VARIABLE_tabCoordinatorIdentifier___TabCoordinator {
    @EnumIdentable
    nonisolated enum Destination {
        case destination
    }
}

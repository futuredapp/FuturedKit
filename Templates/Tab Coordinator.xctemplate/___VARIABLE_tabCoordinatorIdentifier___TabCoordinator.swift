//  ___FILEHEADER___

import EnumIdentable
import FuturedArchitecture
import SwiftUI

@Observable
final class ___VARIABLE_tabCoordinatorIdentifier___TabCoordinator: @MainActor TabCoordinator {
    nonisolated enum AppTab {
        case firstTab
        case secondTab
    }

    private let container: Container

    var selectedTab: AppTab
    var modalCover: ModalCoverModel<Destination>?

    init(container: Container, selectedTab: AppTab) {
        self.container = container
        self.selectedTab = selectedTab
    }

    @ViewBuilder
    static func rootView(with instance: ___VARIABLE_tabCoordinatorIdentifier___TabCoordinator) -> some View {
        TabContentFlow(coordinator: instance) {
            Tab("First", systemImage: "1.circle", value: AppTab.firstTab) {
                Text("First Tab")
            }

            Tab("Second", systemImage: "2.circle", value: AppTab.secondTab) {
                Text("Second Tab")
            }
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

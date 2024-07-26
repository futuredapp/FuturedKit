//  ___FILEHEADER___

import FuturedArchitecture
import SwiftUI

final class ___VARIABLE_tabCoordinatorIdentifier___TabCoordinator: TabCoordinator {
    enum Destination: String, Hashable, Identifiable {
        case destination

        var id: String {
            rawValue
        }
    }

    enum Tab {
        case firstTab
        case secondTab
    }

    private let container: Container

    @Published var selectedTab: Tab
    @Published var sheet: Destination?
    @Published var fullscreenCover: Destination?
    @Published var alertModel: AlertModel?

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

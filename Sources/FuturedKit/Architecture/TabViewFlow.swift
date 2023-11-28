import SwiftUI

struct TabViewFlow<TabViewCoordinator: TabCoordinator, Content: View>: View {
    @StateObject var coordinator: TabViewCoordinator
    @ViewBuilder let content: () -> Content

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            content()
        }
        .sheet(item: $coordinator.sheet, onDismiss: coordinator.onSheetDismiss, content: coordinator.scene(for:))
    }
}

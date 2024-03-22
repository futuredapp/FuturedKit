import SwiftUI

public protocol Coordinator: ObservableObject {
    associatedtype Destination: Hashable & Identifiable
    associatedtype RootView: View
    associatedtype DestinationViews: View

    @ViewBuilder
    static func rootView(with instance: Self) -> RootView

    var sheet: Destination? { get set }
    var fullscreenCover: Destination? { get set }
    var alertModel: AlertModel? { get set }

    @ViewBuilder
    func scene(for destination: Destination) -> DestinationViews
    func onSheetDismiss()
}

public extension Coordinator {
    func present(sheet: Destination) {
        Task { @MainActor in
            self.sheet = sheet
        }
    }

    func dismissSheet() {
        Task { @MainActor in
            self.sheet = nil
        }
    }

    func onSheetDismiss() {}
}

public extension Coordinator {
    func present(fullscreenCover: Destination) {
        Task { @MainActor in
            self.fullscreenCover = fullscreenCover
        }
    }

    func dismissFullscreenCover() {
        Task { @MainActor in
            self.fullscreenCover = nil
        }
    }

    func onFullscreenCoverDismiss() {}
}

public protocol TabCoordinator: Coordinator {
    associatedtype Tab: Hashable

    var selectedTab: Tab { get set }
}

public protocol NavigationStackCoordinator: Coordinator {
    var path: [Destination] { get set }
}

public extension NavigationStackCoordinator {
    func navigate(to destination: Destination) {
        Task { @MainActor in
            self.path.append(destination)
        }
    }

    func pop() {
        Task { @MainActor in
            self.path.removeLast()
        }
    }

    func pop(to destination: Destination?) {
        Task { @MainActor in
            let index = destination.flatMap(self.path.lastIndex(of:)) ?? self.path.startIndex
            self.path = Array(path[path.startIndex...index])
        }
    }
}

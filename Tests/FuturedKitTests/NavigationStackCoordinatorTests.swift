import FuturedArchitecture
import SwiftUI
import Testing

@Suite("NavigationStackCoordinator")
@MainActor
struct NavigationStackCoordinatorTests {
    private enum Destination: Hashable, Identifiable {
        case detail(id: Int)
        case detailVariant(id: Int, title: String)
        case settings

        var id: String {
            switch self {
            case let .detail(id), let .detailVariant(id, _):
                "detail-\(id)"
            case .settings:
                "settings"
            }
        }
    }

    private final class TestCoordinator: NavigationStackCoordinator {
        var path: [Destination] = []
        var modalCover: ModalCoverModel<Destination>?

        static func rootView(with _: TestCoordinator) -> some View {
            EmptyView()
        }

        func scene(for _: Destination) -> some View {
            EmptyView()
        }
    }

    // MARK: navigate(to:)

    @Test("navigate(to:) pushes the destination")
    func navigatePushes() {
        let coordinator = TestCoordinator()
        coordinator.navigate(to: .settings)
        #expect(coordinator.path == [.settings])
    }

    @Test("navigate(to:) ignores a destination whose id matches the top of the stack")
    func navigateIgnoresDuplicateTop() {
        let coordinator = TestCoordinator()
        coordinator.navigate(to: .detail(id: 1))
        coordinator.navigate(to: .detail(id: 1))
        #expect(coordinator.path == [.detail(id: 1)])
    }

    @Test("navigate(to:) compares by id, not by equality")
    func navigateComparesById() {
        let coordinator = TestCoordinator()
        coordinator.navigate(to: .detail(id: 1))
        coordinator.navigate(to: .detailVariant(id: 1, title: "Other"))
        #expect(coordinator.path == [.detail(id: 1)])
    }

    @Test("navigate(to:) pushes the same case with a different id")
    func navigatePushesDifferentId() {
        let coordinator = TestCoordinator()
        coordinator.navigate(to: .detail(id: 1))
        coordinator.navigate(to: .detail(id: 2))
        #expect(coordinator.path == [.detail(id: 1), .detail(id: 2)])
    }

    @Test("navigate(to:) pushes a destination already present lower in the stack")
    func navigatePushesNonTopDuplicate() {
        let coordinator = TestCoordinator()
        coordinator.navigate(to: .detail(id: 1))
        coordinator.navigate(to: .settings)
        coordinator.navigate(to: .detail(id: 1))
        #expect(coordinator.path == [.detail(id: 1), .settings, .detail(id: 1)])
    }

    // MARK: pop()

    @Test("pop() removes the topmost destination")
    func popRemovesTop() {
        let coordinator = TestCoordinator()
        coordinator.path = [.detail(id: 1), .settings]
        coordinator.pop()
        #expect(coordinator.path == [.detail(id: 1)])
    }

    @Test("pop() on an empty stack is a no-op")
    func popOnEmptyStack() {
        let coordinator = TestCoordinator()
        coordinator.pop()
        #expect(coordinator.path.isEmpty)
    }
}

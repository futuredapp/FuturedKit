//  ___FILEHEADER___

import SwiftUI

final class ___PACKAGENAME:identifier___AppCoordinator: ObservableObject {
    private var container: ___PACKAGENAME:identifier___Container

    init(container: ___PACKAGENAME:identifier___Container) {
        self.container = container
    }

    var rootView: some View {
        BaseFlowCoordinator.rootView(
            with: BaseFlowCoordinator(container: container)
        )
    }
}

extension ___PACKAGENAME:identifier___AppCoordinator: ___PACKAGENAME:identifier___AppDelegateProtocol {
    // swiftlint:disable:next discouraged_optional_collection
    func applicationDidFinishLaunching(with launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
    }
}

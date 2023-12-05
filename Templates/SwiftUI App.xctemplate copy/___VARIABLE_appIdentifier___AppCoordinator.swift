//  ___FILEHEADER___

import SwiftUI

final class ___VARIABLE_appIdentifier___AppCoordinator: ObservableObject {
    private var container: Container

    init(container: Container) {
        self.container = container
    }

    var rootView: some View {
        Text("Hello World!")
    }
}

extension ___VARIABLE_appIdentifier___AppCoordinator: ___VARIABLE_appIdentifier___AppDelegateProtocol {
    func applicationDidFinishLaunching(with launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
    }
}

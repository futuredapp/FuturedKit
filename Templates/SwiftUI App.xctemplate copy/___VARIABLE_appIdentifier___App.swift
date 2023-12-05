//  ___FILEHEADER___

import SwiftUI

@main
struct ___VARIABLE_appIdentifier___App: App {
    @UIApplicationDelegateAdaptor
    private var appDelegate: ___VARIABLE_appIdentifier___AppDelegate

    @StateObject
    private var coordinator: ___VARIABLE_appIdentifier___AppCoordinator

    init() {
        let coordinator = ___VARIABLE_appIdentifier___AppCoordinator(container: Container())
        self._coordinator = StateObject(wrappedValue: coordinator)
        self.appDelegate.delegate = coordinator
    }

    var body: some Scene {
        WindowGroup {
            coordinator.rootView
        }
    }
}


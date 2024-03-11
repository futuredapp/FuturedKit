//  ___FILEHEADER___

import SwiftUI

#error("Add https://github.com/futuredapp/FuturedKit.git to the project!")

@main
struct ___PACKAGENAME:identifier___App: App {
    @UIApplicationDelegateAdaptor
    private var appDelegate: ___PACKAGENAME:identifier___AppDelegate

    @StateObject
    private var coordinator: ___PACKAGENAME:identifier___AppCoordinator

    init() {
        let coordinator = ___PACKAGENAME:identifier___AppCoordinator(container: ___PACKAGENAME:identifier___Container())
        self._coordinator = StateObject(wrappedValue: coordinator)
        self.appDelegate.delegate = coordinator
    }

    var body: some Scene {
        WindowGroup {
            coordinator.rootView
        }
    }
}

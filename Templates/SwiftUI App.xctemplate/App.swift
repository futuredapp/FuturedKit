//  ___FILEHEADER___

import SwiftUI

#error("Add https://github.com/futuredapp/FuturedKit.git to the project!")

// swiftlint:disable:next line_length
#warning("Add UILaunchScreen (dictionary) to Info.plist. Without it, iOS runs the app in legacy compatibility mode and the UI does not fill the full screen on modern devices.")

// swiftlint:disable:next line_length
#warning("Drag the 'SwiftLint' build phase above 'Compile Sources' in the target's Build Phases. Xcode templates can only append phases, so SwiftLint --fix corrections currently apply only to the next build instead of the current one.")

@main
struct ___PACKAGENAME:identifier___App: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    @State private var coordinator: AppCoordinator

    init() {
        let coordinator = AppCoordinator(container: Container())
        self._coordinator = State(wrappedValue: coordinator)
        self.appDelegate.delegate = coordinator
    }

    var body: some Scene {
        WindowGroup {
            coordinator.rootView
        }
    }
}

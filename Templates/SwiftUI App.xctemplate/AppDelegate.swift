//  ___FILEHEADER___

import UIKit

// swiftlint:disable discouraged_optional_collection
protocol AppDelegateProtocol: AnyObject {
    func applicationDidFinishLaunching(with launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
}

@Observable
class AppDelegate: UIResponder, UIApplicationDelegate {
    weak var delegate: AppDelegateProtocol?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        delegate?.applicationDidFinishLaunching(with: launchOptions)
        return true
    }
}
// swiftlint:enable discouraged_optional_collection

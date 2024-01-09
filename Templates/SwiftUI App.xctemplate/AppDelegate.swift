//  ___FILEHEADER___

import UIKit

protocol ___PACKAGENAME:identifier___AppDelegateProtocol: AnyObject {
    func applicationDidFinishLaunching(with launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
}

class ___PACKAGENAME:identifier___AppDelegate: UIResponder, UIApplicationDelegate, ObservableObject {
    weak var delegate: ___PACKAGENAME:identifier___AppDelegateProtocol?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        delegate?.applicationDidFinishLaunching(with: launchOptions)
        return true
    }
}

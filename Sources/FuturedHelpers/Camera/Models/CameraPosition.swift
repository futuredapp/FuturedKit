#if canImport(UIKit)

import Foundation

/// Which physical camera the session is currently driving.
public enum CameraPosition: Sendable {
    case back
    case front

    /// Returns the opposite position.
    public var toggled: CameraPosition {
        switch self {
        case .back:
            .front
        case .front:
            .back
        }
    }
}

#endif

#if canImport(UIKit)

import AVFoundation
import Foundation

/// Which physical camera the session is currently driving.
public enum CameraPosition: Sendable {
    case back
    case front

    /// Returns the opposite position.
    public var toggled: CameraPosition {
        switch self {
        case .back: .front
        case .front: .back
        }
    }

    /// Equivalent `AVCaptureDevice.Position` for input lookup.
    public var avPosition: AVCaptureDevice.Position {
        switch self {
        case .back: .back
        case .front: .front
        }
    }
}

#endif

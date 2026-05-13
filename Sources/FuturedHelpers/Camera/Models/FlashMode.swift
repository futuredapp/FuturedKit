#if canImport(UIKit)

import AVFoundation
import Foundation

/// Flash / torch state cycled by the camera UI.
public enum FlashMode: CaseIterable, Sendable {
    case off
    case on
    case auto

    /// SF Symbol that visually represents the current mode.
    public var symbolName: String {
        switch self {
        case .off: "bolt.slash.fill"
        case .on: "bolt.fill"
        case .auto: "bolt.badge.automatic.fill"
        }
    }

    /// Returns the next mode in the cycle: `off` → `on` → `auto` → `off`.
    public var next: FlashMode {
        switch self {
        case .off: .on
        case .on: .auto
        case .auto: .off
        }
    }

    /// AVFoundation flash mode for `AVCapturePhotoSettings`.
    public var avFlashMode: AVCaptureDevice.FlashMode {
        switch self {
        case .off: .off
        case .on: .on
        case .auto: .auto
        }
    }

    /// AVFoundation torch mode for `AVCaptureDevice` during recording.
    public var avTorchMode: AVCaptureDevice.TorchMode {
        switch self {
        case .off: .off
        case .on: .on
        case .auto: .auto
        }
    }
}

#endif

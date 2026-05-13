#if canImport(UIKit)

import Foundation

/// Errors that can be reported by the camera session.
public enum CameraError: Error, Sendable {
    /// The capture pipeline did not produce photo data.
    case noPhotoData
    /// Session configuration failed (missing input, unsupported device, etc.).
    case configurationFailed
    /// The user denied camera or microphone access.
    case permissionDenied
}

#endif

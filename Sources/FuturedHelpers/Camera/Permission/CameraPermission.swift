// Host apps must declare `NSCameraUsageDescription` (always) and `NSMicrophoneUsageDescription`
// (for video) in `Info.plist`; the framework cannot enforce this.

#if canImport(UIKit)

import AVFoundation
import Foundation

/// Convenience wrappers for camera/microphone permission requests.
public enum CameraPermission {
    /// Returns the current camera authorization status.
    public static var cameraStatus: AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .video)
    }

    /// Returns the current microphone authorization status.
    public static var microphoneStatus: AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .audio)
    }

    /// Requests camera access if not yet determined. Returns `true` if authorized.
    @discardableResult
    public static func requestCameraAccess() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }

    /// Requests microphone access if not yet determined. Returns `true` if authorized.
    @discardableResult
    public static func requestMicrophoneAccess() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .audio)
    }
}

#endif

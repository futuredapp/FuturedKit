#if canImport(UIKit)

import Foundation

/// Receives lifecycle and recording events from a ``CameraSession``.
///
/// Callbacks are `nonisolated` and may be invoked from the session's internal
/// dispatch queue. Conforming types are responsible for hopping to their own
/// actor (typically `@MainActor`) before mutating observable state.
public protocol CameraSessionDelegate: AnyObject, Sendable {
    func cameraSessionDidStart()
    func cameraSessionDidStop()
    func cameraSession(didChangePosition position: CameraPosition)
    func cameraSessionRecordingDidStart()
    func cameraSession(recordingDidFinish url: URL?)
    func cameraSession(didFail error: CameraError)
}

#endif

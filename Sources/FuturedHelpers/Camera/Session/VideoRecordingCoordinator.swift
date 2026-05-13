#if canImport(UIKit)

import AVFoundation
import Foundation
import os

/// Owns a single in-flight video recording. Hands AVFoundation a delegate that
/// bridges its callback-based start/finish API to Swift concurrency.
///
/// All public methods are invoked on the session's serial queue.
final class VideoRecordingCoordinator: @unchecked Sendable {
    private let delegate = VideoCaptureDelegate()

    /// Begins recording to a fresh temp `.mov` file. `onStart` fires when
    /// AVFoundation reports the file has actually opened.
    func start(
        on output: AVCaptureMovieFileOutput,
        onStart: @escaping @Sendable () -> Void
    ) {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mov")
        delegate.setStartHandler(onStart)
        output.startRecording(to: url, recordingDelegate: delegate)
    }

    /// Stops an in-flight recording and awaits the file URL. Returns `nil` if
    /// no recording was in flight or AVFoundation reported an error.
    func stop(on output: AVCaptureMovieFileOutput) async -> URL? {
        guard output.isRecording else {
            return nil
        }
        return await withCheckedContinuation { continuation in
            delegate.setContinuation(continuation)
            output.stopRecording()
        }
    }
}

/// Bridges `AVCaptureFileOutputRecordingDelegate` to Swift concurrency. The
/// internal lock guarantees the stored continuation is resumed exactly once
/// even if `setContinuation` is called twice or `stop` is requested before
/// recording actually began.
private final class VideoCaptureDelegate: NSObject, AVCaptureFileOutputRecordingDelegate, @unchecked Sendable {
    private struct State {
        var continuation: CheckedContinuation<URL?, Never>?
        var startHandler: (@Sendable () -> Void)?
    }

    private let state = OSAllocatedUnfairLock(initialState: State())

    func setContinuation(_ continuation: CheckedContinuation<URL?, Never>) {
        let stale = state.withLock { value -> CheckedContinuation<URL?, Never>? in
            let previous = value.continuation
            value.continuation = continuation
            return previous
        }
        stale?.resume(returning: nil)
    }

    func setStartHandler(_ handler: @escaping @Sendable () -> Void) {
        state.withLock { $0.startHandler = handler }
    }

    func fileOutput(
        _ output: AVCaptureFileOutput,
        didStartRecordingTo fileURL: URL,
        from connections: [AVCaptureConnection]
    ) {
        let handler = state.withLock { value -> (@Sendable () -> Void)? in
            let current = value.startHandler
            value.startHandler = nil
            return current
        }
        handler?()
    }

    func fileOutput(
        _ output: AVCaptureFileOutput,
        didFinishRecordingTo outputFileURL: URL,
        from connections: [AVCaptureConnection],
        error: Error?
    ) {
        let continuation = state.withLock { value -> CheckedContinuation<URL?, Never>? in
            let current = value.continuation
            value.continuation = nil
            value.startHandler = nil
            return current
        }

        if error != nil {
            continuation?.resume(returning: nil)
        } else {
            continuation?.resume(returning: outputFileURL)
        }
    }
}

#endif

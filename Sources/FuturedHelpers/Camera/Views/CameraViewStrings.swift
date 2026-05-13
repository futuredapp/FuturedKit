#if canImport(UIKit)

import Foundation

/// Caller-supplied strings shown in ``DefaultCameraView``. The framework does
/// not localize on the consumer's behalf — pass already-localized values.
public struct CameraViewStrings: Sendable {
    public let cancel: String
    public let photoMode: String
    public let videoMode: String
    public let flashAuto: String

    public init(
        cancel: String = "Cancel",
        photoMode: String = "Photo",
        videoMode: String = "Video",
        flashAuto: String = "Auto"
    ) {
        self.cancel = cancel
        self.photoMode = photoMode
        self.videoMode = videoMode
        self.flashAuto = flashAuto
    }

    public static let `default` = CameraViewStrings()

    func label(for mode: CaptureMode) -> String {
        switch mode {
        case .photo: photoMode
        case .video: videoMode
        }
    }
}

#endif

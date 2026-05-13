#if canImport(UIKit)

import Foundation

/// The kind of media the camera session is configured to produce.
public enum CaptureMode: CaseIterable, Sendable {
    case photo
    case video
}

#endif

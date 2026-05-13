#if canImport(UIKit)

import SwiftUI

/// Circular shutter button that morphs between photo, video-idle, and
/// video-recording states.
public struct CameraCaptureButton: View {
    private let mode: CaptureMode
    private let isRecording: Bool
    private let style: CameraViewStyle
    private let action: () -> Void

    public init(
        mode: CaptureMode,
        isRecording: Bool,
        style: CameraViewStyle,
        action: @escaping () -> Void
    ) {
        self.mode = mode
        self.isRecording = isRecording
        self.style = style
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .stroke(style.primaryTextColor, lineWidth: style.captureButtonStrokeWidth)
                    .frame(width: style.captureButtonOuterSize, height: style.captureButtonOuterSize)
                innerShape
            }
        }
    }

    @ViewBuilder
    private var innerShape: some View {
        switch mode {
        case .photo:
            Circle()
                .fill(style.primaryTextColor)
                .frame(width: style.captureButtonInnerSize, height: style.captureButtonInnerSize)
        case .video:
            if isRecording {
                RoundedRectangle(cornerRadius: 4)
                    .fill(style.recordingColor)
                    .frame(width: style.captureButtonStopSize, height: style.captureButtonStopSize)
            } else {
                Circle()
                    .fill(style.recordingColor)
                    .frame(width: style.captureButtonInnerSize, height: style.captureButtonInnerSize)
            }
        }
    }
}

#endif

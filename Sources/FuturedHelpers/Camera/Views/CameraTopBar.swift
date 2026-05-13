#if canImport(UIKit)

import SwiftUI

/// Top row of ``DefaultCameraView``: flash toggle on the left, recording badge
/// or `Auto` flash indicator centred when applicable.
public struct CameraTopBar: View {
    private let flashMode: FlashMode
    private let isRecording: Bool
    private let recordingDuration: TimeInterval
    private let style: CameraViewStyle
    private let strings: CameraViewStrings
    private let onFlashTap: () -> Void

    public init(
        flashMode: FlashMode,
        isRecording: Bool,
        recordingDuration: TimeInterval,
        style: CameraViewStyle,
        strings: CameraViewStrings,
        onFlashTap: @escaping () -> Void
    ) {
        self.flashMode = flashMode
        self.isRecording = isRecording
        self.recordingDuration = recordingDuration
        self.style = style
        self.strings = strings
        self.onFlashTap = onFlashTap
    }

    public var body: some View {
        HStack(spacing: 0) {
            CameraFlashButton(flashMode: flashMode, style: style, action: onFlashTap)
            Spacer()
            if isRecording {
                CameraRecordingIndicator(duration: recordingDuration, style: style)
                Spacer()
            } else if flashMode == .auto {
                CameraFlashBadge(label: strings.flashAuto, style: style)
                Spacer()
            }
        }
        .padding(.horizontal, style.horizontalPadding)
        .padding(.top, style.topPadding)
    }
}

private struct CameraFlashButton: View {
    let flashMode: FlashMode
    let style: CameraViewStyle
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: flashMode.symbolName)
                .font(.system(size: style.iconFontSize))
                .foregroundStyle(flashMode == .off ? style.primaryTextColor : style.accentColor)
                .frame(width: style.iconButtonSize, height: style.iconButtonSize)
        }
    }
}

private struct CameraFlashBadge: View {
    let label: String
    let style: CameraViewStyle

    var body: some View {
        Text(label)
            .font(.caption2.bold())
            .foregroundStyle(style.backgroundColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(style.accentColor, in: Capsule())
    }
}

#endif

#if canImport(UIKit)

import SwiftUI

/// Red dot + monospaced `mm:ss` recording duration, used by ``CameraTopBar``.
public struct CameraRecordingIndicator: View {
    private let duration: TimeInterval
    private let style: CameraViewStyle

    public init(duration: TimeInterval, style: CameraViewStyle) {
        self.duration = duration
        self.style = style
    }

    public var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(style.recordingColor)
                .frame(width: 8, height: 8)
            Text(formattedDuration)
                .font(.system(.caption, design: .monospaced).bold())
                .foregroundStyle(style.primaryTextColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.black.opacity(0.6), in: Capsule())
    }

    private var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#endif

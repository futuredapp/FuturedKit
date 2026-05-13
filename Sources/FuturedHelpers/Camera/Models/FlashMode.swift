#if canImport(UIKit)

import Foundation

/// Flash / torch state cycled by the camera UI.
public enum FlashMode: CaseIterable, Sendable {
    case off
    case on
    case auto

    /// SF Symbol that visually represents the current mode.
    public var symbolName: String {
        switch self {
        case .off:
            "bolt.slash.fill"
        case .on:
            "bolt.fill"
        case .auto:
            "bolt.badge.automatic.fill"
        }
    }

    /// Returns the next mode in the cycle: `off` → `on` → `auto` → `off`.
    public var next: FlashMode {
        let all = FlashMode.allCases
        guard let index = all.firstIndex(of: self) else {
            return self
        }
        return all[(index + 1) % all.count]
    }
}

#endif

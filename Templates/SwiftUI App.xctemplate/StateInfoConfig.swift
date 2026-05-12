//  ___FILEHEADER___

import SwiftUI

/// Configuration used by `StateInfoView` to render non-populated component
/// states (`.empty` and `.error`). The same shape is reused so empty and
/// error views share one visual language.
nonisolated struct StateInfoConfig: Equatable {
    nonisolated struct Action: Equatable {
        let title: String
        let action: @Sendable () async -> Void

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.title == rhs.title
        }
    }

    let icon: Image?
    let title: String
    let message: String?
    let actions: [Action]

    init(
        icon: Image? = nil,
        title: String,
        message: String? = nil,
        actions: [Action] = []
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actions = actions
    }
}

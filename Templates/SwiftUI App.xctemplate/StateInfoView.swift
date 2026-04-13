//  ___FILEHEADER___

import SwiftUI

/// Reusable view that renders a `StateInfoConfig`. Used as the default
/// renderer for `.empty` and `.error` states in `ComponentStateView`.
///
/// TODO: Replace this baseline layout with the project's design system —
/// typography, spacing, icon treatment, button styles, and tokens should
/// match the app. This template provides a minimal SwiftUI implementation
/// only so the architecture compiles out of the box.
struct StateInfoView: View {
    let config: StateInfoConfig

    var body: some View {
        VStack(spacing: 16) {
            if let icon = config.icon {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .foregroundStyle(.secondary)
            }

            Text(config.title)
                .font(.headline)
                .multilineTextAlignment(.center)

            if let message = config.message {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if !config.actions.isEmpty {
                VStack(spacing: 8) {
                    ForEach(Array(config.actions.enumerated()), id: \.offset) { index, action in
                        actionButton(for: action, isPrimary: index == 0)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func actionButton(for action: StateInfoConfig.Action, isPrimary: Bool) -> some View {
        if isPrimary {
            Button(action.title) {
                Task { await action.action() }
            }
            .buttonStyle(.borderedProminent)
        } else {
            Button(action.title) {
                Task { await action.action() }
            }
            .buttonStyle(.bordered)
        }
    }
}

#if DEBUG
#Preview("Empty") {
    StateInfoView(config: .init(
        icon: Image(systemName: "tray"),
        title: "No items yet",
        message: "Pull to refresh or tap the button below.",
        actions: [.init(title: "Refresh", action: {})]
    ))
}

#Preview("Error") {
    StateInfoView(config: .init(
        icon: Image(systemName: "exclamationmark.triangle"),
        title: "Something went wrong",
        message: "We couldn't load this screen. Please try again.",
        actions: [
            .init(title: "Retry", action: {}),
            .init(title: "Cancel", action: {})
        ]
    ))
}
#endif

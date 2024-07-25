import SwiftUI

private struct AlertModifier: ViewModifier {
    @Binding var model: AlertModel?

    init(_ model: Binding<AlertModel?>) {
        self._model = model
    }

    func body(content: Content) -> some View {
        content.alert(
            model?.title ?? "",
            isPresented: .init(
                get: { model != nil },
                set: { isPresented, _ in
                    if !isPresented {
                        model = nil
                    }
                }
            ),
            presenting: model,
            actions: { model in
                if let primaryAction = model.primaryAction {
                    Button(
                        primaryAction.title,
                        role: primaryAction.buttonRole,
                        action: primaryAction.action
                    )

                    if let secondaryAction = model.secondaryAction {
                        Button(
                            secondaryAction.title,
                            role: secondaryAction.buttonRole,
                            action: secondaryAction.action
                        )
                    }
                }
            },
            message: { model in
                if let message = model.message {
                    Text(message)
                }
            }
        )
    }
}

extension View {
    /// Presents an alert to the user.
    /// - Parameters:
    ///   - model: A binding to a `AlertModel` value that determines whether to present the alert
    ///   that you define by this model.
    ///
    /// ## Overview
    ///
    /// Use this method when you need to show simplified an alert to the user.
    /// In the following example, a button presents an alert when tapped, by updating a local `alertModel` property.
    /// Alert contains given `title` and `message` with standard "OK" button
    ///
    /// ```swift
    /// @State private var alertModel: AlertModel?
    /// var body: some View {
    ///     Button("Tap to show alert") {
    ///         alertModel = AlertModel(
    ///             title: "Current Location Not Available",
    ///             message: "Your current location can’t be determined at this time."
    ///         )
    ///     }
    ///     .defaultAlert(model: $alertModel)
    /// }
    /// ```
    public func defaultAlert(model: Binding<AlertModel?>) -> some View {
        modifier(AlertModifier(model))
    }
}

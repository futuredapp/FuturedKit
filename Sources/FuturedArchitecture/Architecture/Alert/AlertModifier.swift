import SwiftUI

private struct AlertModifier: ViewModifier {
    @Binding var model: AlertModel?

    init(_ model: Binding<AlertModel?>) {
        self._model = model
    }

    func body(content: Content) -> some View {
        content.alert(item: $model) { model -> Alert in
            switch model.action {
            case .dismiss(button: let button):
                return Alert(
                    title: Text(model.title),
                    message: model.message.map(Text.init),
                    dismissButton: button ?? .cancel()
                )
            case let .custom(primary: primary, secondary: secondary):
                return Alert(
                    title: Text(model.title),
                    message: model.message.map(Text.init),
                    primaryButton: primary,
                    secondaryButton: secondary
                )
            }
        }
    }
}

extension View {
    /// Presents an alert to the user.
    /// - Parameters:
    ///   - model: A binding to a `Alert` value that determines whether to present the alert
    ///   that you define by this model.
    ///
    /// ## Overview
    ///
    /// Use this method when you need to show an alert to the user.
    /// In the following example, a button presents a simple alert when tapped,
    /// by updating a local `alertModel` property.
    ///
    /// ```swift
    /// @State private var alertModel: AlertModel?
    /// var body: some View {
    ///     Button("Tap to show alert") {
    ///         alertModel = AlertModel(
    ///             title: "Current Location Not Available",
    ///             message: "Your current location can’t be determined at this time.",
    ///             action: .dismiss
    ///         )
    ///     }
    ///     .alert(model: $alertModel)
    /// }
    /// ```
    public func alert(model: Binding<AlertModel?>) -> some View {
        modifier(AlertModifier(model))
    }
}

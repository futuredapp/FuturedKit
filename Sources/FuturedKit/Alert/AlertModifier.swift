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
    /// Creates an alert with specified action.
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - message: The message to display in the body of the alert.
    ///   - action: The specification of the alert action.
    public func alert(model: Binding<AlertModel?>) -> some View {
        modifier(AlertModifier(model))
    }
}

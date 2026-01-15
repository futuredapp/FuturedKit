import SwiftUI

/// A model representation of an alert, which is used by `defaultAlert(model: AlertModel)` SwiftUI View modifier
///
/// ## Overview
///
/// It wraps the native `alert(_:isPresented:presenting:actions:message:)`, but you show an alert in different way by using the `defaultAlert(model:)` view modifier,
/// which then appears whenever the bound `model` value is not `nil` value.
/// Alert model contains two actions: `primaryAction` and `secondaryAction`, which are then represented as SwiftUI Button
/// If both values are nil, system presents alert with standard "OK" button and given `title` and `message`
/// If one of the actions contains `destructive` button role and there is no `cancel` button role, system will add standard button with "Cancel" title.
/// If both `primaryAction` and `secondaryAction` actions have `destructive` button roles, system will still add standard "Cancel" button to the alert.
///
/// In the following example, a button presents a simple alert when tapped, by updating a local `alertModel` property.
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
///
/// The following example adds primary “Delete” button with `destructive` button role and standard "Cancel" button which is added by system.
///
/// ```swift
/// @State private var alertModel: AlertModel?
/// var body: some View {
///     Button("Tap to show alert") {
///         alertModel = AlertModel(
///             title: "Unable to Save Workout Data",
///             message: "The connection to the server was lost.",
///             primaryAction: AlertModel.ButtonAction(
///                 title: "Delete,
///                 buttonRole: .destructive,
///                 action: deleteWorkoutData
///             )
///         )
///     }
///     .defaultAlert(model: $alertModel)
/// }
/// ```
///
/// The alert handles its own dismissal when the user taps one of the buttons in the alert,
/// by setting the bound `model` value back to `nil`.
public struct AlertModel: Identifiable {
    public struct ButtonAction {
        let title: String
        let buttonRole: ButtonRole?
        let action: () -> Void

        public init(title: String, buttonRole: ButtonRole? = nil, action: @escaping () -> Void) {
            self.title = title
            self.buttonRole = buttonRole
            self.action = action
        }
    }

    public struct TextField {
        let title: String
        let text: Binding<String>

        public init(title: String, text: Binding<String>) {
            self.title = title
            self.text = text
        }
    }

    public var id: String? {
        title + (message ?? "")
    }

    let title: String
    let message: String?
    let textField: TextField?
    let primaryAction: ButtonAction?
    let secondaryAction: ButtonAction?

    /// Creates an alert model.
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - message: The message to display in the body of the alert.
    ///   - primaryAction: The specification of the alert primary action.
    ///   - secondaryAction: The specification of the alert secondary action.
    public init(
        title: String,
        message: String?,
        textField: TextField? = nil,
        primaryAction: ButtonAction? = nil,
        secondaryAction: ButtonAction? = nil
    ) {
        self.title = title
        self.message = message
        self.textField = textField
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }
}

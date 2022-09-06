import SwiftUI

/// A representation of an alert presentation.
///
/// ## Overview
///
/// It wrappes the native `Alert`, but you show an alert in different way by using the `alert(model:)` view modifier,
/// which then appears whenever the bound `model` value is not `nil` value.
/// Binded value is exactly an alert model which defines the alert view so you don't create a view content manually.
///
/// In the following example, a button presents a simple alert when tapped, by updating a local `alertModel` property.
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
///
/// To specify alert action you can use `.dismiss` or `.custom` instance of the ``Action`` type.
/// The following example uses two buttons: a default button labeled “Try Again” that calls a `saveWorkoutData` method,
/// and a “Delete” button that calls a destructive `deleteWorkoutData` method.
///
/// ```swift
/// @State private var alertModel: AlertModel?
/// var body: some View {
///     Button("Tap to show alert") {
///         alertModel = AlertModel(
///             title: "Unable to Save Workout Data",
///             message: "The connection to the server was lost.",
///             action: .custom(
///                 primary: .default(Text("Try Again"), action: saveWorkoutData),
///                 secondary: .destructive(Text("Delete"), action: deleteWorkoutData)
///             )
///         )
///     }
///     .alert(model: $alertModel)
/// }
/// ```
///
/// The alert handles its own dismissal when the user taps one of the buttons in the alert,
/// by setting the bound `model` value back to `nil`.
public struct AlertModel: Identifiable {
    /// A representation of the alert actions.
    public enum Action {
        /// It provides single button with optional `Alert.Button` instance parameter. Default value is `nil`.
        /// If the `button` parameter is set to nil an alert uses `.cancel` button by defaul.
        case dismiss(button: Alert.Button? = nil)
        /// It provides two custom buttons, specified by `primary` and `secondary` parameters.
        case custom(primary: Alert.Button, secondary: Alert.Button)
    }

    public var id: String? {
        title + (message ?? "")
    }

    let title: String
    let message: String?
    let action: Action

    /// Creates an alert model.
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - message: The message to display in the body of the alert.
    ///   - action: The specification of the alert action.
    public init(title: String, message: String? = nil, action: AlertModel.Action) {
        self.title = title
        self.message = message
        self.action = action
    }
}

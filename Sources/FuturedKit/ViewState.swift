import Foundation
import SwiftUI

/// Typealias formalizing separation of logic to view state instead
/// of having all the state management tools in the view.
///
/// ## Overview
///
/// View state is convenience typealias allowing to separate all
/// data management types like `State` and `EnvironmentObject`
/// into a type encapsulating logic for each view.
///
/// Types conforming to this protocol can use standard data management tools
/// supplied by SwiftUI. It enables having only one property in the view
/// and separating all the others to a view state to formalize architecture.
/// This replaces the need to use views for state management.
///
/// ## Discussion
///
/// All the storage should be done using SwiftUI data management tools,
/// this is the reason why the wrapped value is not mutable. This enables
/// automatic updates of the view which uses the view model.
///
/// ```swift
/// struct TapViewState: ViewState {
///     @State private(set) var tapCount: UInt = 0
///
///     func tapButton() {
///         tapCount += 1
///     }
/// }
///
/// struct TapView: View {
///     let state = TapViewState()
///
///     var body: some View {
///         Button(action: state.tapButton) {
///             Label("Tapped \(state.tapCount)", systemImage: "hand.tap")
///         }
///     }
/// }
/// ```
public typealias ViewState = DynamicProperty

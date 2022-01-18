import Foundation
import SwiftUI

/// Requirement which all the view models need to fulfill so they can
/// be added using ``ViewModel`` property wrapper.
///
/// ## Overview
///
/// Types conforming to this protocol can use standard data management tools
/// supplied by SwiftUI. It enables having only one property wrapped in the view
/// and separating all the others to a view model to formalize architecture.
///
/// ```swift
/// struct TapViewModel: ViewModelProtocol {
///     @State private(set) var tapCount: UInt = 0
///
///     func tapButton() {
///         tapCount += 1
///     }
/// }
/// ```
///
/// ## Discussion
///
/// Currently, it is only typealias making clear that the dynamic
/// property is made to be used in ``ViewModel`` property wrapper.
public typealias ViewModelProtocol = DynamicProperty

/// Property wrapper formalizing separation of logic to view model instead
/// of having all the state management tools in the view.
///
/// ## Overview
///
/// View model is convenience architecture wrapper allowing to separate all
/// data managementy types like `State` and `EnvironmentObject`
/// into a type ancapsulating logic for each view.
///
/// This replaces the need to use views for state management.
///
/// ## Discussion
///
/// All the storage should be done using SwiftUI data management tools,
/// this is the reason why the wrapped value is not mutable. This enables
/// automatic updates of the view which uses the view model.
///
/// ```swift
/// struct TapViewModel: ViewModelProtocol {
///     @State private(set) var tapCount: UInt = 0
///
///     func tapButton() {
///         tapCount += 1
///     }
/// }
///
/// struct TapView: View {
///     @ViewModel private var viewModel = TapViewModel()
///
///     var body: some View {
///         Button(action: viewModel.tapButton) {
///             Label("Tapped \(viewModel.tapCount)", systemImage: "hand.tap")
///         }
///     }
/// }
/// ```
@propertyWrapper
public struct ViewModel<VM: ViewModelProtocol>: DynamicProperty {
    public private(set) var wrappedValue: VM

    /// Creates new view model property wrapper with a wrapped value of concrete
    /// view model.
    /// - Parameter wrappedValue: Concrete view model conforming
    ///       to ``ViewModelProtocol``.
    public init(wrappedValue: VM) {
        self.wrappedValue = wrappedValue
    }
}

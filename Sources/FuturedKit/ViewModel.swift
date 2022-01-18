import Foundation
import SwiftUI

public typealias ViewModelProtocol = DynamicProperty

/// Property wrapper formalizing separation of logic to view model instead
/// of having another view as a view model.
///
/// ## Overview
///
/// View model is convenience architecture wrapper allowing to separate all
/// data managementy types like `State` and `EnvironmentObject`
/// into a type ancapsulating logic for each view.
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

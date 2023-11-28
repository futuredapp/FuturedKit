import SwiftUI

/// A type-erased shape.
///
/// ## Overview
///
/// An `AnyShape` allows changing the type of shape used in a given view
/// hierarchy. You can use it when different shapes are presented in the same
/// place but using `AnyView` is too broad since it is not possible to apply
/// `Shape` related modifiers.
///
/// ```swift
/// var body: some Shape {
///     (isCapsule ? AnyShape(Capsule()) : AnyShape(Rectangle()))
///         .stroke()
/// }
/// ```
public struct AnyShape: Shape {
    private let path: (CGRect) -> Path

    /// Create an instance that type-erases a shape.
    /// - Parameter shape: Concrete type conforming to `Shape`.
    public init<S>(_ shape: S) where S: Shape {
        self.path = shape.path
    }

    /// Describes this shape as a path within a rectangular frame of reference.
    ///
    /// - Parameter rect: The frame of reference for describing this shape.
    ///
    /// - Returns: A path that describes this shape.
    public func path(in rect: CGRect) -> Path {
        self.path(rect)
    }
}

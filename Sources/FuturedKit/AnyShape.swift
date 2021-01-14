import SwiftUI

public struct AnyShape: Shape {
    private let path: (CGRect) -> Path

    public init<S>(_ shape: S) where S: Shape {
        self.path = shape.path
    }

    public func path(in rect: CGRect) -> Path {
        self.path(rect)
    }
}

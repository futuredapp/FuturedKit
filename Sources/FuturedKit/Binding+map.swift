import SwiftUI

extension Binding {
    @inlinable
    public func map<T>(forth: @escaping (Value) -> T, back: @escaping (T) -> Value) -> Binding<T> {
        Binding<T>(
            get: { forth(self.wrappedValue) },
            set: { value in
                self.wrappedValue = back(value)
            }
        )
    }
}

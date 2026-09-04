//  ___FILEHEADER___

protocol CacheProjection: Equatable {
    associatedtype CacheModel: Equatable
    associatedtype Data: Equatable & Mockable
    associatedtype ID // swiftlint:disable:this type_name

    var state: ComponentState { get set }
    var data: Data { get set }

    static func empty(state: ComponentState) -> Self

    /// Extract projection from the entire cache (for global/singleton data).
    static func data(from cache: CacheModel) -> Self?

    /// Extract projection for a specific ID (for keyed data).
    static func data(for id: ID, from cache: CacheModel) -> Self?
}

/// Default `data(for:from:)` for projections that don't use an ID.
/// Projections with a real `ID` type are forced to implement it.
extension CacheProjection where ID == Void {
    static func data(for id: ID, from cache: CacheModel) -> Self? {
        nil
    }
}

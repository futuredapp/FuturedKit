//  ___FILEHEADER___

protocol CacheProjection: Equatable {
    associatedtype CacheModel: Equatable
    associatedtype Data: Equatable & Mockable
    associatedtype ID

    var state: ComponentState { get set }
    var data: Data { get set }

    static func empty(state: ComponentState) -> Self

    /// Extract projection from the entire cache (for global/singleton data).
    static func data(from cache: CacheModel) -> Self?

    /// Extract projection for a specific ID (for keyed data).
    static func data(for id: ID, from cache: CacheModel) -> Self?
}

extension CacheProjection {
    static func data(from cache: CacheModel) -> Self? {
        nil
    }

    static func data(for id: ID, from cache: CacheModel) -> Self? {
        nil
    }
}

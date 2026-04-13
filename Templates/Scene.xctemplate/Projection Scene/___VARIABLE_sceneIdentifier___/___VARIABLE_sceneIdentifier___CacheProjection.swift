//  ___FILEHEADER___

import ProxyMembers

@dynamicMemberLookup
nonisolated struct ___VARIABLE_sceneIdentifier___CacheProjection: CacheProjection {
    typealias ID = Void // swiftlint:disable:this type_name

    var state: ComponentState
    @ProxyMembers var data: ___VARIABLE_sceneIdentifier___Data

    static func empty(state: ComponentState) -> Self {
        Self(state: state, data: .mock)
    }

    static func data(from cache: DataCacheModel) -> Self? {
        // TODO: Map cache data to projection
        nil
    }
}

nonisolated struct ___VARIABLE_sceneIdentifier___Data: Equatable, Mockable {
    // TODO: Add data properties

    static var mock: Self {
        Self()
    }
}

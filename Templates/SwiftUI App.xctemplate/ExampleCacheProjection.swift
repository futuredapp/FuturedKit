//  ___FILEHEADER___

import ProxyMembers

@dynamicMemberLookup
nonisolated struct ExampleCacheProjection: CacheProjection {
    typealias ID = Void // swiftlint:disable:this type_name

    var state: ComponentState
    @ProxyMembers var data: ExampleData

    static func empty(state: ComponentState) -> Self {
        Self(state: state, data: .mock)
    }

    static func data(from cache: DataCacheModel) -> Self? {
        guard let item = cache.exampleItem else {
            return nil
        }
        return Self(
            state: .ready,
            data: ExampleData(title: item.title)
        )
    }
}

nonisolated struct ExampleData: Equatable, Mockable {
    var title: String

    static var mock: Self {
        Self(title: "Loading...")
    }
}

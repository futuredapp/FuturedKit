//  ___FILEHEADER___

import FuturedArchitecture

protocol ___VARIABLE_sceneIdentifier___ComponentModelProtocol: ComponentModel {
    func onAppear() async
}

final class ___VARIABLE_sceneIdentifier___ComponentModel: ___VARIABLE_sceneIdentifier___ComponentModelProtocol {

    let onEvent: (Event) -> Void

    private let dataCache: DataCache<DataCacheModel>
    private let resource: ___VARIABLE_sceneIdentifier___Resource

    init(
        dataCache: DataCache<DataCacheModel>,
        resource: ___VARIABLE_sceneIdentifier___Resource,
        onEvent: @escaping (Event) -> Void
    ) {
        self.dataCache = dataCache
        self.resource = resource
        self.onEvent = onEvent
    }

    func onAppear() async {
        // Subscribe to dataCache changes
        // Fetch fresh data
    }
}

extension ___VARIABLE_sceneIdentifier___ComponentModel {
    enum Event {}
}

#if DEBUG
final class ___VARIABLE_sceneIdentifier___ComponentModelMock: ___VARIABLE_sceneIdentifier___ComponentModelProtocol {
    typealias Event = ___VARIABLE_sceneIdentifier___ComponentModel.Event

    var onEvent: (Event) -> Void = { _ in }

    func onAppear() async {}
}
#endif

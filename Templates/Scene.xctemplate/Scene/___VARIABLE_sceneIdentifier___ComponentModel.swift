//  ___FILEHEADER___

import FuturedArchitecture

protocol ___VARIABLE_sceneIdentifier___ComponentModelProtocol: ComponentModel {
    func onAppear() async
}

final class ___VARIABLE_sceneIdentifier___ComponentModel: ___VARIABLE_sceneIdentifier___ComponentModelProtocol {

    let onEvent: (Event) -> Void

    private let dataCache: DataCache<DataCacheModel>

    init(
        dataCache: DataCache<DataCacheModel>,
        onEvent: @escaping (Event) -> Void
    ) {
        self.dataCache = dataCache
        self.onEvent = onEvent
    }

    func onAppear() async {
        // Subscribe to dataCache changes
        // Fetch fresh data
    }
}

extension ___VARIABLE_sceneIdentifier___ComponentModel {
    enum Event {

    }
}

final class ___VARIABLE_sceneIdentifier___ComponentModelMock: ___VARIABLE_sceneIdentifier___ComponentModelProtocol {
    typealias Event = ___VARIABLE_sceneIdentifier___ComponentModel.Event

    var onEvent: (___VARIABLE_sceneIdentifier___ComponentModel.Event) -> Void = { _ in }
    
    func onAppear() async {
    }
}

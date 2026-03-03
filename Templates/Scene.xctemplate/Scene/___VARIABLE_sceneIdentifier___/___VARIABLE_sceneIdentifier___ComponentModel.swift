//  ___FILEHEADER___

import FuturedArchitecture
import Observation

protocol ___VARIABLE_sceneIdentifier___ComponentModelProtocol: ComponentModel {
    func onAppear() async
}

@Observable
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
        // Fetch fresh data from network or subscribe to cache changes
    }
}

extension ___VARIABLE_sceneIdentifier___ComponentModel {
    enum Event {}
}

#if DEBUG
@Observable
final class ___VARIABLE_sceneIdentifier___ComponentModelMock: ___VARIABLE_sceneIdentifier___ComponentModelProtocol {
    typealias Event = ___VARIABLE_sceneIdentifier___ComponentModel.Event

    var onEvent: (Event) -> Void = { _ in }

    func onAppear() async {}
}
#endif

//  ___FILEHEADER___

import FuturedArchitecture

protocol BaseComponentModelProtocol: ComponentModel {
    func onAppear() async
    func onTouchUpInside()
}

final class BaseComponentModel: BaseComponentModelProtocol {

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

    func onTouchUpInside() {
        onEvent(.touchEvent)
    }
}

extension BaseComponentModel {
    enum Event {
        case touchEvent
    }
}

#if DEBUG
final class BaseComponentModelMock: BaseComponentModelProtocol {
    typealias Event = BaseComponentModel.Event

    var onEvent: (BaseComponentModel.Event) -> Void = { _ in }

    func onAppear() async { }

    func onTouchUpInside() { }
}
#endif
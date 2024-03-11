//  ___FILEHEADER___

import FuturedArchitecture

protocol ExampleComponentModelProtocol: ComponentModel {
    func onAppear() async
    func onTouchUpInside()
}

final class ExampleComponentModel: ExampleComponentModelProtocol {

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

extension ExampleComponentModel {
    enum Event {
        case touchEvent
        case alert(title: String, message: String)
    }
}

#if DEBUG
final class ExampleComponentModelMock: ExampleComponentModelProtocol {
    typealias Event = ExampleComponentModel.Event

    var onEvent: (ExampleComponentModel.Event) -> Void = { _ in }

    func onAppear() async { }

    func onTouchUpInside() { }
}
#endif
//___FILEHEADER___

import FuturedArchitecture

final class Container {
    private(set) var dataCache = DataCache(value: DataCacheModel())

    init() {
        // Init services
    }

    func resetContainer() {
        // Reset services
        dataCache = DataCache(value: DataCacheModel())
    }
}

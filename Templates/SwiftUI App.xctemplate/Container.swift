//  ___FILEHEADER___

import FuturedArchitecture

final class ___PACKAGENAME:identifier___Container {
    private(set) var dataCache = DataCache(value: DataCacheModel())

    init() {
        // Init services
    }

    func resetContainer() {
        // Reset services
        self.dataCache = DataCache(value: DataCacheModel())
    }
}

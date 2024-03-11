//  ___FILEHEADER___

import FuturedArchitecture

final class ___PACKAGENAME:identifier___Container {
    private(set) var dataCache = DataCache(value: ___PACKAGENAME:identifier___DataCacheModel())

    init() {
        // Init services
    }

    func resetContainer() {
        // Reset services
        self.dataCache = DataCache(value: ___PACKAGENAME:identifier___DataCacheModel())
    }
}

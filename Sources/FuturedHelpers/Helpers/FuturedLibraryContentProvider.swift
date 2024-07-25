import SwiftUI

@available(macOS 11, iOS 14, watchOS 7, tvOS 14, *)
struct FuturedLibraryContentProvider: LibraryContentProvider {
    var views: [LibraryItem] {
        LibraryItem(AnyShape(Circle()))
    }
}

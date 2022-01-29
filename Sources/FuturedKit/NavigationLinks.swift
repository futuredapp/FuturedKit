import SwiftUI
///
/// ViewModifier and protocol for creating and handling NavigationLinks
///
/// ```swift
/// enum HomeLinks: NavigationLinks {
///     case detail, settings, profile
/// }
///
/// struct HomeScene: some View {
///     @State navigationState: HomeLinks?
///
///     var body: some View {
///        homeViewContent.pushNavigation {
///             HomeLinks.detail.link(to: DetailScene(), selection: $navigationState)
///             HomeLinks.settings.link(to: SettingsScene(), selection: $navigationState)
///             HomeLinks.profile.link(to: ProfileScene(), selection: $navigationState)
///     }
///
///     func showDetail() {
///         navigationState = .detail
///     }
/// }
/// ```

/// Protocol, by which you should specify and create links to different destinations
public protocol NavigationLinks: Hashable {
    func link<Destination: View>(to destination: Destination, selection: Binding<Self?>) -> NavigationLink<EmptyView, Destination>
}

public extension NavigationLinks {
    func link<Destination: View>(to destination: Destination, selection: Binding<Self?>) -> NavigationLink<EmptyView, Destination> {
        NavigationLink(destination: destination, tag: self, selection: selection, label: EmptyView.init)
    }
}

/// Wraps the view and its navigation links
struct NavigationLinksWrapper<Links: View>: ViewModifier {
    let navigationLinks: Links

    init(@ViewBuilder links: @escaping () -> Links) {
        navigationLinks = links()
    }

    init(links: Links) {
        navigationLinks = links
    }

    func body(content: Content) -> some View {
        ZStack {
            navigationLinks
            content
        }
    }
}

public extension View {
    func pushNavigation<Links: View>(@ViewBuilder links: @escaping () -> Links) -> some View {
        modifier(NavigationLinksWrapper(links: links))
    }
}

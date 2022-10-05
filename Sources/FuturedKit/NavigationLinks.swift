import SwiftUI
///
/// ## Overview
///
/// Use ``NavigationLinks`` to define all the possibilities of push navigation
/// for a certain view and create its `NavigationLink` in one place of your view.
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
///
/// ViewModifier and protocol for creating and handling NavigationLinks.
/// Use ``NavigationLinks`` protocol to define push navigation destinations and create its `NavigationLink`.
///
public protocol NavigationLinks: Hashable {
    func link<Destination: View>(
        to destination: Destination,
        selection: Binding<Self?>
    ) -> NavigationLink<EmptyView, Destination>
}

public extension NavigationLinks {
    func link<Destination: View>(
        to destination: Destination,
        selection: Binding<Self?>
    ) -> NavigationLink<EmptyView, Destination> {
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
        if #available(macOS 11.0, iOS 14.0, *) {
            ZStack {
                navigationLinks
                    .accessibilityHidden(true)
                content
            }
        } else {
            ZStack {
                navigationLinks
                content
            }
        }
    }
}

public extension View {
    func pushNavigation<Links: View>(@ViewBuilder links: @escaping () -> Links) -> some View {
        modifier(NavigationLinksWrapper(links: links))
    }
}

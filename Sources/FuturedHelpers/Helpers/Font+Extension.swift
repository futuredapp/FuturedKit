#if canImport(UIKit)

import SwiftUI

extension Font.TextStyle {

    /// The UIKit dynamic text style to use for fonts.
    public var uiFontTextStyle: UIFont.TextStyle {
        switch self {
        case .largeTitle:
            return .largeTitle
        case .title:
            return .title1
        case .title2:
            return .title2
        case .title3:
            return .title3
        case .headline:
            return .headline
        case .subheadline:
            return .subheadline
        case .body:
            return .body
        case .callout:
            return .callout
        case .footnote:
            return .footnote
        case .caption:
            return .caption1
        case .caption2:
            return .caption2
        case .extraLargeTitle:
            if #available(iOS 17.0, *) {
                return .extraLargeTitle
            } else {
                return .largeTitle
            }
        case .extraLargeTitle2:
            if #available(iOS 17.0, *) {
                return .extraLargeTitle2
            } else {
                return .largeTitle
            }
        @unknown default:
            return .body
        }
    }
}

extension Font.Weight {
    /// The UIKit weight that represents standard typeface style.
    public var uiFontWeight: UIFont.Weight {
        switch self {
        case .ultraLight:
            .ultraLight
        case .thin:
            .thin
        case .regular:
            .regular
        case .medium:
            .medium
        case .semibold:
            .semibold
        case .bold:
            .bold
        case .heavy:
            .heavy
        case .black:
            .black
        default:
            .regular
        }
    }
}

extension Font.Width {
    /// AThe UIKit width to use for fonts that have multiple widths.
    public var uiFontWidth: UIFont.Width {
        switch self {
        case .compressed:
            .compressed
        case .condensed:
            .condensed
        case .expanded:
            .expanded
        case .standard:
            .standard
        default:
            .standard
        }
    }
}

extension Font.Design {
    /// The UIKit design that describes the system-defined typeface designs.
    public var uiDesign: UIFontDescriptor.SystemDesign {
        switch self {
        case .default:
            .default
        case .monospaced:
            .monospaced
        case .rounded:
            .rounded
        case .serif:
            .serif
        @unknown default:
            .default
        }
    }
}

#endif

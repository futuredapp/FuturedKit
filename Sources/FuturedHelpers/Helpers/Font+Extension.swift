#if canImport(UIKit)

import SwiftUI

extension Font.TextStyle {

    /// The UIKit dynamic text style to use for fonts.
    public var uiFontTextStyle: UIFont.TextStyle {
        switch self {
        case .largeTitle:
            .largeTitle
        case .title:
            .title1
        case .title2:
            .title2
        case .title3:
            .title3
        case .headline:
            .headline
        case .subheadline:
            .subheadline
        case .body:
            .body
        case .callout:
            .callout
        case .footnote:
            .footnote
        case .caption:
            .caption1
        case .caption2:
            .caption2
        case .extraLargeTitle:
            .extraLargeTitle
        case .extraLargeTitle2:
            .extraLargeTitle2
        @unknown default:
            .body
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

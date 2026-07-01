import Foundation

extension AttributeContainer {
    /// A "strongly emphasized" (bold) attribute container backed by `inlinePresentationIntent`.
    ///
    /// Emphasis is expressed as an *intent* rather than a concrete font, so SwiftUI `Text` and
    /// UIKit both render it bold relative to the surrounding text and it stays correct across
    /// Dynamic Type sizes and font families. This is the default styling applied by
    /// ``Swift/AttributedString/emphasizing(_:in:with:)``.
    public static var stronglyEmphasized: AttributeContainer {
        var container = AttributeContainer()
        container.inlinePresentationIntent = .stronglyEmphasized
        return container
    }
}

extension AttributedString {
    /// Builds an attributed string from `template` and applies `attributes` to the first
    /// occurrence of `emphasized`.
    ///
    /// The common "localized sentence with one emphasized run" pattern — e.g. bolding the email
    /// in *"An account with **you@example.com** already exists."*. When `emphasized` is empty or
    /// not found, `template` is returned with no attributes applied.
    ///
    /// - Parameters:
    ///   - emphasized: The substring to style. Only its first occurrence is affected.
    ///   - template: The full text, typically a localized string.
    ///   - attributes: Attributes merged onto the matched range. Defaults to
    ///     ``Foundation/AttributeContainer/stronglyEmphasized`` (bold).
    /// - Returns: The attributed `template` with `attributes` applied to the first match.
    public static func emphasizing(
        _ emphasized: some StringProtocol,
        in template: String,
        with attributes: AttributeContainer = .stronglyEmphasized
    ) -> AttributedString {
        emphasizing(emphasized, in: template) { attributed, range in
            attributed[range].mergeAttributes(attributes)
        }
    }

    private static func emphasizing(
        _ emphasized: some StringProtocol,
        in template: String,
        applying: (inout AttributedString, Range<AttributedString.Index>) -> Void
    ) -> AttributedString {
        var attributed = AttributedString(template)
        guard !emphasized.isEmpty, let range = attributed.range(of: emphasized) else {
            return attributed
        }
        applying(&attributed, range)
        return attributed
    }
}

#if canImport(UIKit)
extension AttributedString {
    /// Builds an attributed string from `template` and applies `style` to the first occurrence
    /// of `emphasized`.
    ///
    /// A `TextStyle`-driven counterpart to ``Swift/AttributedString/emphasizing(_:in:with:)`` so
    /// the emphasized run can pull font, kerning, and decoration straight from the design system
    /// instead of a hand-built ``Foundation/AttributeContainer``. Applies the same attributes as
    /// ``Swift/AttributedStringProtocol/stylize(with:)``.
    ///
    /// - Parameters:
    ///   - emphasized: The substring to style. Only its first occurrence is affected.
    ///   - template: The full text, typically a localized string.
    ///   - style: The text style applied to the matched range.
    /// - Returns: The attributed `template` with `style` applied to the first match.
    public static func emphasizing(
        _ emphasized: some StringProtocol,
        in template: String,
        style: TextStyle
    ) -> AttributedString {
        emphasizing(emphasized, in: template) { attributed, range in
            attributed[range].stylize(with: style)
        }
    }
}
#endif

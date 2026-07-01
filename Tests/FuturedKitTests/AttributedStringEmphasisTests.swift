import Foundation
@testable import FuturedHelpers
import Testing

@Suite("AttributedString emphasis")
struct AttributedStringEmphasisTests {
    private func emphasizedRuns(in attributed: AttributedString) -> [String] {
        attributed.runs
            .filter { $0.inlinePresentationIntent == .stronglyEmphasized }
            .map { String(attributed[$0.range].characters) }
    }

    @Test("stronglyEmphasized container carries the bold intent")
    func stronglyEmphasizedContainer() {
        let container = AttributeContainer.stronglyEmphasized
        #expect(container.inlinePresentationIntent == .stronglyEmphasized)
    }

    @Test("default emphasizes the matched substring in bold")
    func defaultBoldsSubstring() {
        let result = AttributedString.emphasizing("you@example.com", in: "Account you@example.com exists.")
        #expect(emphasizedRuns(in: result) == ["you@example.com"])
    }

    @Test("full plain text is preserved")
    func preservesPlainText() {
        let template = "Account you@example.com exists."
        let result = AttributedString.emphasizing("you@example.com", in: template)
        #expect(String(result.characters) == template)
    }

    @Test("only the first occurrence is emphasized")
    func firstOccurrenceOnly() {
        let result = AttributedString.emphasizing("aa", in: "aa bb aa")
        #expect(emphasizedRuns(in: result) == ["aa"])
    }

    @Test("missing substring returns the template unstyled")
    func missingSubstring() {
        let template = "No match here."
        let result = AttributedString.emphasizing("zzz", in: template)
        #expect(String(result.characters) == template)
        #expect(emphasizedRuns(in: result).isEmpty)
    }

    @Test("empty substring returns the template unstyled")
    func emptySubstring() {
        let template = "Nothing to emphasize."
        let result = AttributedString.emphasizing("", in: template)
        #expect(String(result.characters) == template)
        #expect(emphasizedRuns(in: result).isEmpty)
    }

    @Test("a custom container is merged onto the matched range")
    func customContainer() {
        var container = AttributeContainer()
        container.inlinePresentationIntent = .emphasized
        let result = AttributedString.emphasizing("world", in: "hello world", with: container)

        let italicRuns = result.runs
            .filter { $0.inlinePresentationIntent == .emphasized }
            .map { String(result[$0.range].characters) }
        #expect(italicRuns == ["world"])
        #expect(emphasizedRuns(in: result).isEmpty)
    }
}

#if canImport(UIKit)
@Suite("AttributedString emphasis with TextStyle")
struct AttributedStringEmphasisTextStyleTests {
    private static var emphasis: TextStyle {
        TextStyle(
            fontType: .system(weight: .bold),
            size: 16,
            lineHeight: 20
        )
    }

    @Test("TextStyle overload applies the style font to the matched range")
    func appliesStyleFont() {
        let result = AttributedString.emphasizing("world", in: "hello world", style: Self.emphasis)

        let styledText = result.runs
            .filter { $0.font != nil }
            .map { String(result[$0.range].characters) }
        #expect(styledText == ["world"])
    }

    @Test("TextStyle overload leaves the template unstyled when the substring is missing")
    func missingSubstringLeavesUnstyled() {
        let template = "hello there"
        let result = AttributedString.emphasizing("world", in: template, style: Self.emphasis)
        #expect(String(result.characters) == template)
        #expect(result.runs.allSatisfy { $0.font == nil })
    }
}
#endif

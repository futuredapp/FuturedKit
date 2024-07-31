//
//  EnumIdentifiersGeneratorMacro.swift
//
//
//  Created by Simon Sestak on 31/07/2024.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics
import Foundation

public struct EnumIdentifiersGeneratorMacro: MemberMacro {
    public static func expansion<Declaration, Context>(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context) throws -> [SwiftSyntax.DeclSyntax] where Declaration : SwiftSyntax.DeclGroupSyntax, Context : SwiftSyntaxMacros.MacroExpansionContext {

            guard let declaration = declaration.as(EnumDeclSyntax.self) else {
                let enumError = Diagnostic(node: node._syntaxNode, message: Diagnostics.mustBeEnum)
                context.diagnose(enumError)
                return []
            }

            guard let enumCases: [SyntaxProtocol] = declaration.memberBlock
                .children(viewMode: .fixedUp).filter({ $0.kind == .memberDeclList })
                .first?
                .children(viewMode: .fixedUp).filter({ $0.kind == SyntaxKind.memberDeclListItem })
                .flatMap({ $0.children(viewMode: .fixedUp).filter({ $0.kind == .enumCaseDecl })})
                .flatMap({ $0.children(viewMode: .fixedUp).filter({ $0.kind == .enumCaseElementList })})
                .flatMap({ $0.children(viewMode: .fixedUp).filter({ $0.kind == .enumCaseElement })})
            else {
                let enumError = Diagnostic(node: node._syntaxNode, message: Diagnostics.mustHaveCases)
                context.diagnose(enumError)
                return []
            }

            let caseIds: [String] = enumCases.compactMap { enumCase in
                guard let firstToken = enumCase.firstToken(viewMode: .fixedUp) else {
                    return nil
                }

                guard case let .identifier(id) = firstToken.tokenKind else {
                    return nil
                }

                return id
            }

            guard !caseIds.isEmpty else {
                let enumError = Diagnostic(node: node._syntaxNode, message: Diagnostics.mustHaveCases)
                context.diagnose(enumError)
                return []
            }

            let modifier = declaration.hasPublicModifier ? "public " : ""
            let enumID = "\(modifier)enum CaseID: String, Hashable, CaseIterable, CustomStringConvertible {\n\(caseIds.map { "  case \($0)\n" }.joined())\n  \(modifier)var description: String {\nself.rawValue\n  }\n}"
            let idAccessor = "\(modifier)var caseId: CaseID {\n  switch self {\n\(caseIds.map { "  case .\($0): .\($0)\n" }.joined())  }\n}"
            let identifierVariable = "var id: String { self.caseId.rawValue }"
            let hashableConformance = "func hash(into hasher: inout Hasher) {\nhasher.combine(id)\n}"
            let comparableConformance = "static func == (lhs: Self, rhs: Self) -> Bool {\nlhs.id == rhs.id\n}"

            return [
                DeclSyntax(stringLiteral: enumID),
                DeclSyntax(stringLiteral: idAccessor),
                DeclSyntax(stringLiteral: identifierVariable),
                DeclSyntax(stringLiteral: hashableConformance),
                DeclSyntax(stringLiteral: comparableConformance)
            ]
        }

    public enum Diagnostics: String, DiagnosticMessage {

        case mustBeEnum, mustHaveCases

        public var message: String {
            switch self {
            case .mustBeEnum:
                return "`@EnumIdentifiersGeneratorMacro` can only be applied to an `enum`"
            case .mustHaveCases:
                return "`@EnumIdentifiersGeneratorMacro` can only be applied to an `enum` with `case` statements"
            }
        }

        public var diagnosticID: MessageID {
            MessageID(domain: "EnumIdentifiersGeneratorMacro", id: rawValue)
        }

        public var severity: DiagnosticSeverity { .error }
    }
}

private extension DeclGroupSyntax {
    var hasPublicModifier: Bool {
        self.modifiers.children(viewMode: .fixedUp)
            .compactMap { syntax in
                syntax.as(DeclModifierSyntax.self)?
                    .children(viewMode: .fixedUp)
                    .contains { syntax in
                        switch syntax.as(TokenSyntax.self)?.tokenKind {
                        case .keyword(.public):
                            return true
                        default:
                            return false
                        }
                    }
            }
            .contains(true)
    }
}

@main
struct MacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        EnumIdentifiersGeneratorMacro.self,
    ]
}

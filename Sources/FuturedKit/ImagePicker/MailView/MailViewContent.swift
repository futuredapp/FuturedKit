import Foundation

/// Default field values of `MailView`.
public struct MailViewContent {
    public let subject: String?
    public let toRecipients: [String]?
    public let ccRecipients: [String]?
    public let bccRecipients: [String]?
    public let messageBody: (body: String, isHtml: Bool)?
    public let attachmentData: [(attachment: Data, mimeType: String, fileName: String)]
    public let preferredSendingEmailAddress: String?
    
    /// Creates a mail view content defining fields default values.
    /// - Parameters:
    ///   - subject: The initial text for the subject line of the email.
    ///   - toRecipients: The initial recipients to include in the email’s To field.
    ///   - ccRecipients: The initial recipients to include in the email’s Cc field.
    ///   - bccRecipients: The initial recipients to include in the email’s Bcc field.
    ///   - messageBody: The initial body text to include in the email.
    ///   - attachmentData: The specified data as an attachment to the message.
    ///   - preferredSendingEmailAddress: The preferred email address to use in the From field, if such an address is available.
    public init(
        subject: String? = nil,
        toRecipients: [String]? = nil,
        ccRecipients: [String]? = nil,
        bccRecipients: [String]? = nil,
        messageBody: (body: String, isHtml: Bool)? = nil,
        attachmentData: [(attachment: Data, mimeType: String, fileName: String)] = [],
        preferredSendingEmailAddress: String? = nil
    ) {
        self.subject = subject
        self.toRecipients = toRecipients
        self.ccRecipients = ccRecipients
        self.bccRecipients = bccRecipients
        self.messageBody = messageBody
        self.attachmentData = attachmentData
        self.preferredSendingEmailAddress = preferredSendingEmailAddress
    }
}

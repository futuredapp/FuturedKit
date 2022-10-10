import Foundation

/// Default field values of `MailView`.
public struct MailViewContent {
    public let subject: String?
    public let toRecipients: [String]?
    public let ccRecipients: [String]?
    public let bccRecipients: [String]?
    public let messageBody: (body: String, isHtml: Bool)?
    public let attachments: [Attachement]
    public let preferredSendingEmailAddress: String?

    /// Creates a mail view content defining fields default values of ``MailView``.
    /// - Parameters:
    ///   - subject: The initial text for the subject line of the email.
    ///   - toRecipients: The initial recipients to include in the email’s To field.
    ///   - ccRecipients: The initial recipients to include in the email’s Cc field.
    ///   - bccRecipients: The initial recipients to include in the email’s Bcc field.
    ///   - messageBody: The initial body text to include in the email.
    ///   - attachments: The specified data as an attachment to the message.
    ///   - preferredSendingEmailAddress: The preferred email address to use in the From field, if such an address is available.
    public init(
        subject: String? = nil,
        toRecipients: [String]? = nil,
        ccRecipients: [String]? = nil,
        bccRecipients: [String]? = nil,
        messageBody: (body: String, isHtml: Bool)? = nil,
        attachments: [Attachement] = [],
        preferredSendingEmailAddress: String? = nil
    ) {
        self.subject = subject
        self.toRecipients = toRecipients
        self.ccRecipients = ccRecipients
        self.bccRecipients = bccRecipients
        self.messageBody = messageBody
        self.attachments = attachments
        self.preferredSendingEmailAddress = preferredSendingEmailAddress
    }

    /// An attachement of ``MailViewContent``.
    public struct Attachement {
        public let data: Data
        public let mimeType: String
        public let fileName: String
        
        /// Creates a data which can be attached to the mail message.
        /// - Parameters:
        ///   - data: The data to attach. Typically, this is the contents of a file that you want to include.
        ///   - mimeType: The MIME type of the specified data.
        ///   (For example, the MIME type for a JPEG image is `image/jpeg`.)
        ///   - fileName: The preferred filename to associate with the data.
        public init(data: Data, mimeType: String, fileName: String) {
            self.data = data
            self.mimeType = mimeType
            self.fileName = fileName
        }
    }
}

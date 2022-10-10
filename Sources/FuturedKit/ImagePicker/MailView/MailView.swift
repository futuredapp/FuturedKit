#if canImport(MessageUI)

import MessageUI
import SwiftUI

/// Wrapped `MFMailComposeViewController`.
///
/// ## Overview
///
/// Use this view to display a standard email interface inside your app. You can populate fields initial
/// values for the subject, email recipients, body text, and attachments of the email via `content` property.
/// After presenting the interface, the user can edit your initial values before sending the email.
///
/// > Important: After presenting a mail view, the system ignores any attempts to modify the email using
/// `content` attribute. The user can still edit the content of the email, but your app cannot.
/// Therefore, always configure the fields of your email before presenting the mail view.
///
/// # Checking the Result of the Operation
///
/// The mail compose view controller is not dismissed automatically. When the user taps the buttons to send the email
/// or cancel the interface, the mail view calls the `completion` block. Using that you can check the result
/// of the operation and you must dismiss the mail view explicitly.
///
/// The user can delete a queued message before it is sent. Although the view controller reports the success or failure
/// of the operation to its delegate, this class does not provide a way for you to verify whether the email was
/// actually sent.
///
/// # Checking the Availability of the MailView
///
/// Before using the mail view, always call the the `canSendMail()` method to see if the current device is configured
/// to send email. If the user’s device is not set up for the delivery of email, you can notify the user or simply
/// disable the email dispatch features in your application.
/// You should not attempt to use this view if the `canSendMail()` method returns false.
public struct MailView: View {
    let content: MailViewContent
    let completion: (Result<MFMailComposeResult, Error>) -> Void
    
    
    /// Returns a Boolean that indicates whether the current device is able to send email.
    /// ## Discussion
    /// You should call this method before attempting to display the mail view.
    /// If it returns false, you must not display the mail view.
    /// - Returns: `true` if the device is configured for sending email or `false` if it is not.
    public static func canSendMail() -> Bool {
        MFMailComposeViewController.canSendMail()
    }
    
    /// Creates a mail view.
    /// - Parameters:
    ///   - content: The default values of the mail fields.
    ///   - completion: The block to execute after the user taps the buttons to send the email or cancel the interface.
    public init(content: MailViewContent = .init(), completion: @escaping (Result<MFMailComposeResult, Error>) -> Void) {
        self.content = content
        self.completion = completion
    }

    public var body: some View {
        WrappedMFMailComposeViewController(content: content, completion: completion)
            .edgesIgnoringSafeArea(.all)
    }
}

#endif

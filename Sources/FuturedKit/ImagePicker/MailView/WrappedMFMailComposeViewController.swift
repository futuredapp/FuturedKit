import MessageUI
import SwiftUI

struct WrappedMFMailComposeViewController: UIViewControllerRepresentable {
    let content: MailViewContent
    let completion: (Result<MFMailComposeResult, Error>) -> Void
    
    init(content: MailViewContent = .init(), completion: @escaping (Result<MFMailComposeResult, Error>) -> Void) {
        self.content = content
        self.completion = completion
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<WrappedMFMailComposeViewController>
    ) -> MFMailComposeViewController {
        let viewController = MFMailComposeViewController()
        viewController.mailComposeDelegate = context.coordinator
        return viewController
    }

    func updateUIViewController(
        _ uiViewController: MFMailComposeViewController,
        context: UIViewControllerRepresentableContext<WrappedMFMailComposeViewController>
    ) {
        update(uiViewController, with: content)
        context.coordinator.completion = context.coordinator.completion
    }
    
    private func update(_ viewController: MFMailComposeViewController, with content: MailViewContent) {
        if let subject = content.subject {
            viewController.setSubject(subject)
        }
        if let toRecipients = content.toRecipients {
            viewController.setToRecipients(toRecipients)
        }
        if let ccRecipients = content.ccRecipients {
            viewController.setCcRecipients(ccRecipients)
        }
        if let bccRecipients = content.bccRecipients {
            viewController.setBccRecipients(bccRecipients)
        }
        if let (body, isHtml) = content.messageBody {
            viewController.setMessageBody(body, isHTML: isHtml)
        }
        content.attachmentData.forEach { attachment, mimeType, fileName in
            viewController.addAttachmentData(attachment, mimeType: mimeType, fileName: fileName)
        }
        if let preferredSendingEmailAddress = content.preferredSendingEmailAddress {
            viewController.setPreferredSendingEmailAddress(preferredSendingEmailAddress)
        }
    }
    
    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var completion: (Result<MFMailComposeResult, Error>) -> Void

        init(completion: @escaping (Result<MFMailComposeResult, Error>) -> Void) {
            self.completion = completion
        }

        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(result))
            }
        }
    }
}

//
//  ZapMessages
//
//  Created by Otto Suess on 13.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Library
import Messages
import UIKit

class MessagesViewController: MSMessagesAppViewController, ContainerViewController {
    // swiftlint:disable:next private_outlet
    @IBOutlet weak var container: UIView?
    var currentViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let requestViewModel = RequestViewModelFactory.create() {
            guard let viewController = storyboard?.instantiateViewController(withIdentifier: "MessagesRequestViewController") as? MessagesRequestViewController
                else { fatalError("missing vc") }
            viewController.delegate = self
            viewController.requestViewModel = requestViewModel
            setContainerContent(viewController)
        } else {
            guard let viewController = storyboard?.instantiateViewController(withIdentifier: "ConnectionErrorViewController") else { fatalError("missing vc") }
            setContainerContent(viewController)
        }
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        guard let viewController = currentViewController as? MessagesRequestViewController else { return }
        viewController.updatePresentationStyle(to: presentationStyle)
    }
    
    override func willBecomeActive(with conversation: MSConversation) {
        guard let message = conversation.selectedMessage else { return }
        handleSelectedMessage(message)
    }
    
    override func willSelect(_ message: MSMessage, conversation: MSConversation) {
        handleSelectedMessage(message)
    }
    
    func handleSelectedMessage(_ message: MSMessage) {
        guard
            let url = message.url,
            let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems,
            let invoice = queryItems.first(where: { $0.name == "invoice" })?.value,
            let invoiceUrl = URL(string: invoice)
            else { return }
        self.extensionContext?.open(invoiceUrl, completionHandler: nil)
    }
}

extension MessagesViewController: MessagesRequestViewControllerDelegate {
    func insertMessage(text: String, invoice: String) {
        let message = MSMessage()
        
        let layout = MSMessageTemplateLayout()
        
        if !text.isEmpty {
            layout.caption = text
        } else {
            layout.caption = "zap invoice"
        }
        message.layout = layout

        var components = URLComponents()
        components.host = "zap.jackmallers.com"
        components.scheme = "https"
        let queryItem = URLQueryItem(name: "payment_request", value: invoice)
        components.queryItems = [queryItem]
        components.path = "/zapme"
        message.url = components.url
        
        activeConversation?.insert(message, completionHandler: nil)
        dismiss()
    }
}

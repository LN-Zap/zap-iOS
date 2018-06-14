//
//  ZapMessages
//
//  Created by Otto Suess on 13.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Messages
import UIKit
import ZapShared

class MessagesViewController: MSMessagesAppViewController, ContainerViewController {
    // swiftlint:disable:next private_outlet
    @IBOutlet weak var container: UIView?
    var currentViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let requestViewModel = RequestViewModelFactory.create() {
            guard let viewController = storyboard?.instantiateViewController(withIdentifier: "ReceiveViewController") as? ReceiveViewController
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
        guard let viewController = currentViewController as? ReceiveViewController else { return }
        viewController.updatePresentationStyle(to: presentationStyle)
    }
}

extension MessagesViewController: ReceiveViewControllerDelegate {
    func insertText(_ text: String) {
        activeConversation?.insertText(text, completionHandler: nil)
        dismiss()
    }
}

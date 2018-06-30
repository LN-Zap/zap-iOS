//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static func instantiateSendOnChainViewController(with sendOnChainViewModel: SendOnChainViewModel) -> SendOnChainViewController {
        let viewController = Storyboard.sendOnChain.instantiate(viewController: SendOnChainViewController.self)
        viewController.sendOnChainViewModel = sendOnChainViewModel
        return viewController
    }
}

final class SendOnChainViewController: UIViewController, QRCodeScannerChildViewController {
    weak var delegate: QRCodeScannerChildDelegate?
    
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var amountInputView: AmountInputView!
    @IBOutlet private weak var gradientLoadingButtonView: GradientLoadingButtonView!
    
    let contentHeight: CGFloat = 550 // QRCodeScannerChildViewController
    fileprivate var sendOnChainViewModel: SendOnChainViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "scene.send.title".localized
        
        Style.label.apply(to: addressLabel)

        gradientLoadingButtonView.title = "scene.send.send_button".localized
        
        addressLabel.text = sendOnChainViewModel?.address
        
        amountInputView.validRange = sendOnChainViewModel?.validRange
    }
    
    @IBAction private func updateAmount(_ sender: Any) {
        sendOnChainViewModel?.amount = amountInputView.satoshis
    }
    
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func sendButtonTapped(_ sender: Any) {
        sendOnChainViewModel?.send { [weak self] in
            self?.delegate?.dismissSuccessfully()
        }
    }
}

//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

final class SendOnChainViewController: UIViewController, QRCodeScannerChildViewController {
    
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var amountInputView: AmountInputView!
    @IBOutlet private weak var gradientLoadingButtonView: GradientLoadingButtonView!
    
    let contentHeight: CGFloat = 550 // QRCodeScannerChildViewController
    var sendOnChainViewModel: SendOnChainViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "scene.withdraw.title".localized
        
        Style.label.apply(to: addressLabel)

        gradientLoadingButtonView.title = "Send"
        
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
            self?.dismiss(animated: true, completion: nil)
        }
    }
}

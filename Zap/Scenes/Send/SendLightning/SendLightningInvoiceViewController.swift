//
//  Zap
//
//  Created by Otto Suess on 05.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class SendLightningInvoiceViewController: UIViewController {
    
    @IBOutlet private weak var paymentRequestView: UIStackView!
    @IBOutlet private weak var memoLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var paymentBackground: UIView!
    
    var sendViewModel: SendLightningInvoiceViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Style.button.apply(to: sendButton)
        Style.label.apply(to: memoLabel)
        
        sendViewModel?.memo
            .bind(to: memoLabel.reactive.text)
            .dispose(in: reactive.bag)
        
        sendViewModel?.satoshis
            .observeNext { [amountLabel] satoshis in
                guard let satoshis = satoshis else { return }
                amountLabel?.setAmount(satoshis)
            }
            .dispose(in: reactive.bag)
    }
    
    @IBAction private func sendButtonTapped(_ sender: Any) {
        sendViewModel?.send()
    }
}

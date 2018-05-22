//
//  Zap
//
//  Created by Otto Suess on 22.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

final class OpenChannelViewController: UIViewController, QRCodeScannerChildViewController {
    weak var delegate: QRCodeScannerChildDelegate?
    
    @IBOutlet private weak var helpLabel: UILabel!
    @IBOutlet private weak var helpImageView: UIImageView!
    @IBOutlet private weak var amountInputView: AmountInputView!
    @IBOutlet private weak var gradientLoadingButton: GradientLoadingButtonView!
    
    var openChannelViewModel: OpenChannelViewModel?
    let contentHeight: CGFloat = 550 // QRCodeScannerChildViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Style.label.apply(to: helpLabel)
        
        helpImageView.tintColor = Color.text
        helpLabel.text = "Fund connection"
        
        gradientLoadingButton.title = "Add"
        
        amountInputView.satoshis = 1000000
        amountInputView.validRange = (Lnd.Constants.minChannelSize...Lnd.Constants.maxChannelSize)
    }
    
    @IBAction private func presentHelp(_ sender: Any) {
        print("halp")
    }
    
    @IBAction private func updateAmount(_ sender: Any) {
        openChannelViewModel?.amount = amountInputView.satoshis
    }
    
    @IBAction private func openChannel(_ sender: Any) {
        openChannelViewModel?.openChannel { [weak self] in
            self?.delegate?.dismissSuccessfully()
        }
    }    
}

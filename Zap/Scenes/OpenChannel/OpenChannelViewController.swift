//
//  Zap
//
//  Created by Otto Suess on 22.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit
import SVProgressHUD

final class OpenChannelViewController: UIViewController {
    
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var helpLabel: UILabel!
    @IBOutlet private weak var helpImageView: UIImageView!
    @IBOutlet private weak var amountInputView: AmountInputView!
    
    var openChannelViewModel: OpenChannelViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Style.label.apply(to: helpLabel)
        Style.button.apply(to: sendButton) {
            $0.tintColor = .white
        }
        
        helpImageView.tintColor = Color.text
        helpLabel.text = "Fund connection"
        sendButton.setTitle("Add", for: .normal)
        
        amountInputView.amountViewModel = openChannelViewModel
    }
    
    @IBAction private func presentHelp(_ sender: Any) {
        print("halp")
    }
    
    @IBAction private func openChannel(_ sender: Any) {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultAnimationType(.native)
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        SVProgressHUD.show()
        openChannelViewModel?.openChannel { [weak self] in
            SVProgressHUD.dismiss()
            UIApplication.shared.endIgnoringInteractionEvents()
            self?.dismiss(animated: true, completion: nil)
        }
    }    
}

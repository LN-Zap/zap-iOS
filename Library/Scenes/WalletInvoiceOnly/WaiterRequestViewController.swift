//
//  Library
//
//  Created by Otto Suess on 18.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftBTC

extension UIStoryboard {
    static func instantiateWaiterRequestViewController(waiterRequestViewModel: WaiterRequestViewModel) -> WaiterRequestViewController {
        let waiterRequestViewController = StoryboardScene.WalletInvoiceOnly.waiterRequestViewController.instantiate()
        waiterRequestViewController.waiterRequestViewModel = waiterRequestViewModel
        return waiterRequestViewController
    }
}

final class WaiterRequestViewController: UIViewController {
    var waiterRequestViewModel: WaiterRequestViewModel?

    @IBOutlet private weak var protocolSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var qrCodeImageView: UIImageView!
    @IBOutlet private weak var detailStackView: UIStackView!
    @IBOutlet private weak var waitingLabel: UILabel!
    private var addressLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let waiterRequestViewModel = waiterRequestViewModel else { fatalError("waiterRequestViewModel not set") }
        
        view.backgroundColor = UIColor.Zap.background
        
        protocolSegmentedControl.setTitle("Lightning", forSegmentAt: 0)
        protocolSegmentedControl.setTitle("On-Chain", forSegmentAt: 1)
        
        Style.Label.subHeadline.apply(to: waitingLabel)
        waitingLabel.text = "Waiting for payment"
        
        title = "Pay"
        
        guard
            let primaryAmountString = Settings.shared.primaryCurrency.value.format(satoshis: waiterRequestViewModel.amount),
            let secondaryAmountString = Settings.shared.secondaryCurrency.value.format(satoshis: waiterRequestViewModel.amount)
            else { return }
        
        detailStackView.spacing = 15
        detailStackView.set(elements: [
            .horizontalStackView(compressionResistant: .first, content: [
                .label(text: "Amount", style: Style.Label.headline),
                .verticalStackView(content: [
                    .label(text: primaryAmountString, style: Style.Label.body.with { $0.textAlignment = .right }),
                    .label(text: secondaryAmountString, style: Style.Label.subHeadline.with { $0.textAlignment = .right })
                ], spacing: 0)
            ]),
            .separator
        ])
        
        let stackView = detailStackView.addArrangedElement(.horizontalStackView(compressionResistant: .first, content: [
            .label(text: "Address", style: Style.Label.headline),
            .label(text: "Abclkaekllasdfl2345", style: Style.Label.body)
        ]))
        addressLabel = stackView.subviews[1] as? UILabel
        
        changeProtocol(protocolSegmentedControl)
    }
    
    @IBAction private func changeProtocol(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            waiterRequestViewModel?.lightningInvoiceURI { [weak self] in
                self?.displayPaymentURI($0)
            }
        } else {
            waiterRequestViewModel?.bitcoinURI { [weak self] in
                self?.displayPaymentURI($0)
            }
        }
    }
    
    private func displayPaymentURI(_ paymentURI: PaymentURI) {
        qrCodeImageView.image = UIImage.qrCode(from: paymentURI.uriString)
        addressLabel?.text = paymentURI.address
    }
    
    @IBAction private func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

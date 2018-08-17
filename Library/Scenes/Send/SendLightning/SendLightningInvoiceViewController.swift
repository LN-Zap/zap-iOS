//
//  Zap
//
//  Created by Otto Suess on 05.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static func instantiateSendLightningInvoiceViewController(with sendViewModel: SendLightningInvoiceViewModel) -> SendLightningInvoiceViewController {
        let viewController = Storyboard.send.instantiate(viewController: SendLightningInvoiceViewController.self)
        viewController.sendViewModel = sendViewModel
        return viewController
    }
}

final class SendLightningInvoiceViewController: ModalViewController, ContentHeightProviding, QRCodeScannerChildViewController {
    weak var delegate: QRCodeScannerChildDelegate?
    
    @IBOutlet private weak var paymentRequestView: UIStackView!
    @IBOutlet private weak var memoLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var secondaryAmountLabel: UILabel!
    @IBOutlet private weak var paymentBackground: UIView!
    @IBOutlet private weak var destinationLabel: UILabel!
    @IBOutlet private weak var arrowImageView: UIImageView!
    @IBOutlet private weak var gradientButtonView: GradientLoadingButtonView!
    @IBOutlet private weak var expiredView: UIView!
    @IBOutlet private weak var expiredLabel: UILabel!
    
    fileprivate var sendViewModel: SendLightningInvoiceViewModel?
    let contentHeight: CGFloat? = 380 // ContentHeightProviding
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Style.Label.custom().apply(to: memoLabel, amountLabel, secondaryAmountLabel, destinationLabel, expiredLabel)
        amountLabel.font = amountLabel.font.withSize(36)
        secondaryAmountLabel.font = amountLabel.font.withSize(14)
        secondaryAmountLabel.textColor = .gray
        
        gradientButtonView.title = "scene.send.lightning.title".localized
        
        expiredView.backgroundColor = UIColor.Zap.superRed
        expiredLabel.textColor = .white
        
        arrowImageView.tintColor = UIColor.Zap.black
        
        [sendViewModel?.memo.bind(to: memoLabel.reactive.text),
         sendViewModel?.satoshis.bind(to: amountLabel.reactive.text, currency: Settings.shared.primaryCurrency),
         sendViewModel?.destination.bind(to: destinationLabel.reactive.text),
         sendViewModel?.satoshis.bind(to: secondaryAmountLabel.reactive.text, currency: Settings.shared.secondaryCurrency),
         sendViewModel?.invoiceError
            .map({ (error: SendLightningInvoiceError) -> Bool in
                switch error {
                case .none:
                    return true
                default:
                    return false
                }
            })
            .observeOn(DispatchQueue.main)
            .observeNext { [weak self] in
                self?.expiredView.isHidden = $0
                self?.gradientButtonView.isHidden = !$0
            },
         sendViewModel?.invoiceError
            .map({ (error: SendLightningInvoiceError) -> String? in
                switch error {
                    
                case .none:
                    return nil
                case .expired(let date):
                    let date = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
                    return String(format: "scene.send.lightning.error.expired".localized, date)
                case .duplicate:
                    return "scene.send.lightning.error.duplicate".localized
                }
            })
            .ignoreNil()
            .bind(to: expiredLabel.reactive.text)]
            .dispose(in: reactive.bag)
    }
    
    @IBAction private func sendButtonTapped(_ sender: Any) {
        sendViewModel?.send { [weak self] result in
            if let error = result.error {
                DispatchQueue.main.async {
                    self?.delegate?.presentError(message: error.localizedDescription)
                    self?.gradientButtonView.isLoading = false
                }
            } else {
                self?.delegate?.dismissSuccessfully()
            }
        }
    }
}

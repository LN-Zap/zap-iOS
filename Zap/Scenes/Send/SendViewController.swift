//
//  Zap
//
//  Created by Otto Suess on 22.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

class SendViewController: UIViewController {

    @IBOutlet private weak var paymentTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var paymentRequestView: UIStackView!
    @IBOutlet private weak var memoLabel: UILabel!
    @IBOutlet private weak var pasteButton: UIButton!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var paymentBackground: UIView!
    @IBOutlet private weak var scannerView: QRCodeScannerView! {
        didSet {
            scannerView.addressTypes = [.lightningInvoice]
            scannerView.handler = { [weak self] _, address in
                self?.sendViewModel?.updatePaymentRequest(address)
            }
        }
    }

    var viewModel: ViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            sendViewModel = SendViewModel(viewModel: viewModel)
        }
    }
    private var sendViewModel: SendViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "scene.deposit.send".localized
        
        Style.button.apply(to: sendButton, pasteButton)
        pasteButton.setTitleColor(.white, for: .normal)
        Style.label.apply(to: memoLabel)
        
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        paymentTopConstraint.isActive = true
        sendViewModel?.hasPaymentRequest
            .distinct()
            .observeNext { [weak self] hasPaymentRequest in
                UIView.animate(withDuration: 0.25) {
                    self?.paymentTopConstraint.isActive = !hasPaymentRequest
                    self?.view.layoutIfNeeded()
                }
            }
            .dispose(in: reactive.bag)
        
        sendViewModel?.memo
            .bind(to: memoLabel.reactive.text)
            .dispose(in: reactive.bag)
        
        sendViewModel?.satoshis
            .observeNext { [weak self] satoshis in
                guard let satoshis = satoshis else { return }
                self?.amountLabel.setAmount(satoshis)
            }
            .dispose(in: reactive.bag)
    }
    
    @IBAction private func sendButtonTapped(_ sender: Any) {
        sendViewModel?.send()
    }
    
    @IBAction private func pasteButtonTapped(_ sender: Any) {
        sendViewModel?.paste()
    }
    
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

final class WithdrawViewController: UIViewController {
    
    @IBOutlet private weak var allButton: UIButton!
    @IBOutlet private weak var pasteButton: UIButton!
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var addressTextField: UITextField!
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var scannerView: QRCodeScannerView! {
        didSet {
            scannerView.addressType = .bitcoinAddress
            scannerView.handler = { [weak self] address in
                self?.withdrawViewModel?.address.value = address
            }
        }
    }

    var viewModel: ViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            withdrawViewModel = WithdrawViewModel(viewModel: viewModel)
        }
    }
    var withdrawViewModel: WithdrawViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "scene.withdraw.title".localized
        amountTextField?.keyboardType = .decimalPad

        Style.buttonBorder.apply(to: allButton, pasteButton, sendButton)
        
        withdrawViewModel?.address
            .bind(to: addressTextField.reactive.text)
            .dispose(in: reactive.bag)
        
        withdrawViewModel?.amount
            .map { $0.format(unit: .bit) }
            .bind(to: amountTextField.reactive.text)
            .dispose(in: reactive.bag)
    }
    
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func sendButtonTapped(_ sender: Any) {
        withdrawViewModel?.send()
    }
    
    @IBAction private func allButtonTapped(_ sender: Any) {
        withdrawViewModel?.selectAll()
    }
    
    @IBAction private func pasteButtonTapped(_ sender: Any) {
        withdrawViewModel?.paste()
    }
}

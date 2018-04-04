//
//  Zap
//
//  Created by Otto Suess on 22.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

final class OpenChannelViewController: ModalViewController {
    
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var pasteButton: UIButton!
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var createButton: UIButton!
    @IBOutlet private weak var scannerView: QRCodeScannerView! {
        didSet {
            scannerView.addressType = .lightningNode
            scannerView.handler = { [weak self] address in
                self?.openChannelViewModel?.address = address
            }
        }
    }
    
    var viewModel: ViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            openChannelViewModel = OpenChannelViewModel(viewModel: viewModel)
        }
    }
    private var openChannelViewModel: OpenChannelViewModel?
    
    var channelViewModel: ChannelListViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Style.buttonBorder.apply(to: pasteButton, createButton)
        
        title = "scene.open_channel.title".localized
        amountTextField?.text = "100000"
        
//        openChannelViewModel?.address
//            .bind(to: addressLabel.rx.text)
//            .dispose(in: reactive.bag)
//        
//        pasteButton.rx.action = openChannelViewModel?.pasteAction
//
//        createButton.rx
//            .bind(to: openChannelViewModel!.openAction) { [weak self] _ in self?.amountTextField.text } // TODO
//
//        openChannelViewModel?.openAction.elements
//            .subscribe(onNext: { [weak self] _ in
//                self?.dismiss(animated: true, completion: nil)
//            })
//            .dispose(in: reactive.bag)
//
//        openChannelViewModel?.openAction.errors
//            .subscribe(onNext: { [weak self] actionError in
//                if case .underlyingError(let error) = actionError {
//                    self?.displayError(error.localizedDescription)
//                }
//            })
//            .dispose(in: reactive.bag)
    }
    
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

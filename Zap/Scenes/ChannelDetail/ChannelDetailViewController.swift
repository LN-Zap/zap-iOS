//
//  Zap
//
//  Created by Otto Suess on 23.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import SafariServices
import UIKit

class ChannelDetailViewController: ModalViewController {

    @IBOutlet private weak var remotePubKeyLabel: UILabel?
    @IBOutlet private weak var capacityLabel: UILabel?
    @IBOutlet private weak var stateLabel: UILabel?
    @IBOutlet private weak var localBalanceLabel: UILabel?
    @IBOutlet private weak var remoteBalanceLabel: UILabel?
    @IBOutlet private weak var updateCountLabel: UILabel?
    @IBOutlet private weak var blockExplorerButton: UIButton?
    @IBOutlet private weak var closeChannelButton: UIButton!
    
    var channelViewModel: ChannelDetailViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "scene.channel_detail.title".localized
        blockExplorerButton?.setTitle(Settings.blockExplorer.localized, for: .normal)
        
        updateChannel()
        
//        closeChannelButton.rx.action = channelViewModel?.closeAction
//
//        channelViewModel?.closeAction
//            .elements
//            .subscribe(onNext: { [weak self] _ in
//                self?.dismiss(animated: true, completion: nil)
//            })
//            .dispose(in: reactive.bag)
    }

    private func updateChannel() {
        guard let channel = channelViewModel?.channel else { return }
        
        remotePubKeyLabel?.text = channel.remotePubKey
        capacityLabel?.text = String(describing: channel.capacity)
        localBalanceLabel?.text = String(describing: channel.localBalance)
        remoteBalanceLabel?.text = String(describing: channel.remoteBalance)
        updateCountLabel?.text = String(describing: channel.updateCount)
        stateLabel?.setChannelState(channel.state)
    }
    
    @IBAction private func blockExplorerButtonTapped(_ sender: Any) {
        if let txid = channelViewModel?.channel.fundingTransactionId,
            let url = Settings.blockExplorer.url(network: Settings.network, txid: txid) {
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true)
        }
    }
    
    @IBAction private func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

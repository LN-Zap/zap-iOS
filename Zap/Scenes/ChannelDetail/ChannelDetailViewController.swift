//
//  Zap
//
//  Created by Otto Suess on 23.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import SafariServices
import UIKit

class ChannelDetailViewController: ModalViewController {

    @IBOutlet private weak var remotePubKeyLabel: UILabel!
    @IBOutlet private weak var capacityLabel: UILabel!
    @IBOutlet private weak var stateLabel: UILabel!
    @IBOutlet private weak var localBalanceLabel: UILabel!
    @IBOutlet private weak var remoteBalanceLabel: UILabel!
    @IBOutlet private weak var updateCountLabel: UILabel!
    @IBOutlet private weak var blockHeightLabel: UILabel!
    
    @IBOutlet private weak var blockExplorerButton: UIButton!
    @IBOutlet private weak var closeChannelButton: UIButton!
    
    var channelViewModel: ChannelViewModel?
    var viewModel: ViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "scene.channel_detail.title".localized
        blockExplorerButton?.setTitle(Settings.blockExplorer.localized, for: .normal)
        
        updateChannel()
        
        Style.label.apply(to: remotePubKeyLabel,
                          capacityLabel,
                          stateLabel,
                          localBalanceLabel,
                          remoteBalanceLabel,
                          updateCountLabel,
                          blockHeightLabel)
        
        Style.button.apply(to: blockExplorerButton, closeChannelButton)
    }
    
    private func updateChannel() {
        guard let channel = channelViewModel?.channel else { return }
        
        remotePubKeyLabel.text = "remotePubKey: \(channel.remotePubKey)"
        capacityLabel.text = "capacity: \(String(describing: channel.capacity))"
        localBalanceLabel.text = "localBalance: \(String(describing: channel.localBalance))"
        remoteBalanceLabel.text = "remoteBalance: \(String(describing: channel.remoteBalance))"
        updateCountLabel.text = "updateCount: \(String(describing: channel.updateCount ?? 0))"
        
        let blockHeight = (viewModel?.blockHeight.value ?? 0) - channel.blockHeight
        blockHeightLabel.text = "blockHeight: \(String(describing: blockHeight))"
        stateLabel.setChannelState(channel.state)
    }
    
    @IBAction private func closeChannel(_ sender: Any) {
        guard let channelPoint = channelViewModel?.channel.channelPoint else { return }
        viewModel?.closeChannel(channelPoint: channelPoint)
        dismiss(animated: true, completion: nil)
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

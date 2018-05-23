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
        
        titleTextStyle = .dark

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
        
        let capacity = Settings.primaryCurrency.value.format(satoshis: channel.capacity) ?? "-"
        capacityLabel.text = "capacity: \(capacity)"
        
        let localBalance = Settings.primaryCurrency.value.format(satoshis: channel.localBalance) ?? "-"
        localBalanceLabel.text = "localBalance: \(localBalance)"
        
        let remoteBalance = Settings.primaryCurrency.value.format(satoshis: channel.remoteBalance) ?? "-"
        remoteBalanceLabel.text = "remoteBalance: \(remoteBalance)"

        updateCountLabel.text = "updateCount: \(String(describing: channel.updateCount ?? 0))"
        
        let blockHeight = (viewModel?.info.blockHeight.value ?? 0) - channel.blockHeight
        blockHeightLabel.text = "blockHeight: \(String(describing: blockHeight))"
        stateLabel.setChannelState(channel.state)
    }
    
    @IBAction private func closeChannel(_ sender: Any) {
        guard let channel = channelViewModel?.channel else { return }
        
        let alertController = UIAlertController(title: "Close Channel", message: "Do you really want to close channel with node \(channel.remotePubKey)?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let closeAction = UIAlertAction(title: "Close", style: .destructive) { [weak self] _ in
            self?.closeChannel()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(closeAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    private func closeChannel() {
        guard let channelPoint = channelViewModel?.channel.channelPoint else { return }
        viewModel?.channels.close(channelPoint: channelPoint) { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction private func blockExplorerButtonTapped(_ sender: Any) {
        if let txid = channelViewModel?.channel.fundingTransactionId,
            let url = Settings.blockExplorer.url(network: Settings.network, txid: txid) {
            let safariViewController = SFSafariViewController(url: url)
            safariViewController.preferredControlTintColor = UIColor.zap.tint
            present(safariViewController, animated: true)
        }
    }
    
    @IBAction private func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

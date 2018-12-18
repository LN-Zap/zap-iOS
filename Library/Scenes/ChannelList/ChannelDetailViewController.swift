//
//  Library
//
//  Created by Otto Suess on 15.10.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftLnd

final class ChannelDetailViewController: ModalDetailViewController {
    let channelViewModel: ChannelViewModel
    let channelListViewModel: ChannelListViewModel
    
    var presentBlockExplorer: (String, BlockExplorer.CodeType) -> Void
    
    init(channelViewModel: ChannelViewModel, channelListViewModel: ChannelListViewModel, blockExplorerButtonTapped: @escaping (String, BlockExplorer.CodeType) -> Void) {
        self.channelViewModel = channelViewModel
        self.channelListViewModel = channelListViewModel
        self.presentBlockExplorer = blockExplorerButtonTapped
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStackView(channelViewModel)
    }
    
    func setupStackView(_ channelViewModel: ChannelViewModel) {
        addHeadline(channelViewModel.name.value)
        
        let labelStyle = Style.Label.headline
        let textStyle = Style.Label.body
        
        if channelViewModel.channel.state.isClosing {
            contentStackView.addArrangedElement(.horizontalStackView(compressionResistant: .first, content: [
                .label(text: L10n.Scene.ChannelDetail.ClosingTime.label + ":", style: labelStyle),
                .label(text: channelViewModel.csvDelayTimeString, style: textStyle)
            ]))
            contentStackView.addArrangedElement(.separator)
        }
        
        contentStackView.addArrangedElement(.verticalStackView(content: [
            .label(text: L10n.Scene.ChannelDetail.remotePubKeyLabel + ":", style: labelStyle),
            .label(text: channelViewModel.channel.remotePubKey, style: textStyle)
        ], spacing: 0))
        
        contentStackView.addArrangedElement(.separator)
        let balanceView = BalanceView()
        balanceView.set(localBalance: channelViewModel.channel.localBalance, remoteBalance: channelViewModel.channel.remoteBalance)
        
        contentStackView.addArrangedElement(.verticalStackView(content: [
            .customHeight(10, element: .customView(balanceView)),
            .horizontalStackView(compressionResistant: .first, content: [
                .customView(circleIndicatorView(gradient: [UIColor.Zap.lightningOrange, UIColor.Zap.lightningOrangeGradient])),
                .label(text: L10n.Scene.ChannelDetail.localBalanceLabel + ":", style: labelStyle),
                .amountLabel(amount: channelViewModel.channel.localBalance, style: textStyle)
            ]),
            .horizontalStackView(compressionResistant: .first, content: [
                .customView(circleIndicatorView(gradient: [UIColor.Zap.white, UIColor.Zap.white])),
                .label(text: L10n.Scene.ChannelDetail.remoteBalanceLabel + ":", style: labelStyle),
                .amountLabel(amount: channelViewModel.channel.remoteBalance, style: textStyle)
            ])
        ], spacing: 5))
        
        contentStackView.addArrangedElement(.separator)
        let fundingTxId = channelViewModel.channel.channelPoint.fundingTxid
        contentStackView.addArrangedElement(.horizontalStackView(compressionResistant: .first, content: [
            .label(text: L10n.Scene.ChannelDetail.fundingTransactionLabel + ":", style: labelStyle),
            .button(title: fundingTxId, style: Style.Button.custom(fontSize: 14)) { [weak self] _ in
                guard let strongSelf = self else { return }
                
                strongSelf.dismiss(animated: true, completion: {
                    strongSelf.presentBlockExplorer(fundingTxId, .transactionId)
                })
            }
        ]))
        
        if !channelViewModel.channel.state.isClosing {
            let closeTitle = channelViewModel.channel.state == .active ? L10n.Scene.ChannelDetail.closeButton : L10n.Scene.ChannelDetail.forceCloseButton
            
            contentStackView.addArrangedElement(.separator)
            contentStackView.addArrangedElement(.button(title: closeTitle, style: Style.Button.custom(fontSize: 20)) { [weak self] _ in self?.closeChannel() })
        }
    }
    
    private func circleIndicatorView(gradient: [UIColor]) -> UIView {
        let localIndicator = GradientView()
        localIndicator.constrainSize(to: CGSize(width: 10, height: 10))
        localIndicator.layer.cornerRadius = 5
        localIndicator.gradient = gradient
        
        let localIndicatorContainer = UIView()
        localIndicatorContainer.addAutolayoutSubview(localIndicator)
        localIndicatorContainer.constrainCenter(to: localIndicator)
        
        NSLayoutConstraint.activate([
            localIndicator.leadingAnchor.constraint(equalTo: localIndicatorContainer.leadingAnchor),
            localIndicator.trailingAnchor.constraint(equalTo: localIndicatorContainer.trailingAnchor)
        ])
        
        return localIndicatorContainer
    }
    
    private func closeChannel() {
        let alertController = UIAlertController.closeChannelAlertController(channelViewModel: channelViewModel) { [channelViewModel, weak self] in
            guard let strongSelf = self else { return }
            
            let loadingView = strongSelf.presentLoadingView(text: L10n.Scene.Channels.closeLoadingView)
            strongSelf.channelListViewModel.close(channelViewModel.channel) { result in
                DispatchQueue.main.async {
                    strongSelf.dismissAfterClose(result: result, loadingView: loadingView)
                }
            }
        }
        self.present(alertController, animated: true)
    }
    
    private func dismissAfterClose(result: Result<CloseStatusUpdate>, loadingView: LoadingView?) {
        loadingView?.removeFromSuperview()
        
        switch result {
        case .success:
            dismiss(animated: true) {
                Toast.presentSuccess(L10n.Scene.Channels.CloseSuccess.toast)
            }
        case .failure(let error):
            Toast.presentError(error.localizedDescription)
        }
    }
}

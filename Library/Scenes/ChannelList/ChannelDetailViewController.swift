//
//  Library
//
//  Created by Otto Suess on 15.10.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

final class ChannelDetailViewController: ModalDetailViewController {
    let channelViewModel: ChannelViewModel
    let channelListViewModel: ChannelListViewModel
    
    var presentBlockExplorer: (String, BlockExplorer.CodeType) -> Void
    var presentCloseConfirmation: (ChannelViewModel, @escaping () -> Void) -> Void
    
    init(channelViewModel: ChannelViewModel, channelListViewModel: ChannelListViewModel, blockExplorerButtonTapped: @escaping (String, BlockExplorer.CodeType) -> Void, presentCloseConfirmation: @escaping (ChannelViewModel, @escaping () -> Void) -> Void) {
        self.channelViewModel = channelViewModel
        self.channelListViewModel = channelListViewModel
        self.presentBlockExplorer = blockExplorerButtonTapped
        self.presentCloseConfirmation = presentCloseConfirmation
        
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
                .label(text: "scene.channel_detail.closing_time.label".localized + ":", style: labelStyle),
                .label(text: channelViewModel.csvDelayTimeString, style: textStyle)
            ]))
            contentStackView.addArrangedElement(.separator)
        }
        
        contentStackView.addArrangedElement(.verticalStackView(content: [
            .label(text: "scene.channel_detail.remote_pub_key_label".localized + ":", style: labelStyle),
            .label(text: channelViewModel.channel.channelPoint.fundingTxid, style: textStyle)
        ], spacing: 0))
        
        contentStackView.addArrangedElement(.separator)
        let balanceView = BalanceView()
        balanceView.set(localBalance: channelViewModel.channel.localBalance, remoteBalance: channelViewModel.channel.remoteBalance)
        
        let horizontalStackViewHeight = StackViewElement.horizontalStackView(compressionResistant: .first, content: []).height
        
        contentStackView.addArrangedElement(.verticalStackView(content: [
            .customView(balanceView, height: 10),
            .horizontalStackView(compressionResistant: .first, content: [
                .customView(circleIndicatorView(gradient: [UIColor.Zap.lightningOrange, UIColor.Zap.lightningOrangeGradient]), height: horizontalStackViewHeight),
                .label(text: "scene.channel_detail.local_balance_label".localized + ":", style: labelStyle),
                .amountLabel(amount: channelViewModel.channel.localBalance, style: textStyle)
            ]),
            .horizontalStackView(compressionResistant: .first, content: [
                .customView(circleIndicatorView(gradient: [UIColor.Zap.white, UIColor.Zap.white]), height: horizontalStackViewHeight),
                .label(text: "scene.channel_detail.remote_balance_label".localized + ":", style: labelStyle),
                .amountLabel(amount: channelViewModel.channel.remoteBalance, style: textStyle)
            ])
        ], spacing: 5))
        
        contentStackView.addArrangedElement(.separator)
        let fundingTxId = channelViewModel.channel.channelPoint.fundingTxid
        contentStackView.addArrangedElement(.horizontalStackView(compressionResistant: .first, content: [
            .label(text: "scene.channel_detail.funding_transaction_label".localized + ":", style: labelStyle),
            .button(title: fundingTxId, style: Style.Button.custom(fontSize: 14)) { [weak self] _ in
                self?.dismiss(animated: true, completion: {
                    self?.presentBlockExplorer(fundingTxId, .transactionId)
                })
            }
        ]))
        
        if !channelViewModel.channel.state.isClosing {
            let closeTitle = channelViewModel.channel.state == .active ? "scene.channel_detail.close_button".localized : "scene.channel_detail.force_close_button".localized
            
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
        dismiss(animated: true) { [channelViewModel, weak self] in
            self?.presentCloseConfirmation(channelViewModel) {
                let loadingView = self?.presentLoadingView(text: "scene.channels.close_loading_view".localized)
                self?.view.isUserInteractionEnabled = false
                self?.channelListViewModel.close(channelViewModel.channel) {
                    loadingView?.removeFromSuperview()
                    switch $0 {
                    case .success:
                        self?.parent?.presentSuccessToast("scene.channels.close_success.toast".localized)
                    case .failure(let error):
                        self?.parent?.presentErrorToast(error.localizedDescription)
                    }
                }
            }
        }
    }
}

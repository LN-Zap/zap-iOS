//
//  Library
//
//  Created by Otto Suess on 15.10.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftLnd

extension ForceClosingChannel {
    var blocksTilMaturityTimeString: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits =  [.year, .month, .day, .hour, .minute]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 2

        let blockTime: TimeInterval = 10 * 60

        return formatter.string(from: TimeInterval(blocksTilMaturity) * blockTime) ?? ""
    }
}

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

    func setupStackView(_ channelViewModel: ChannelViewModel) { // swiftlint:disable:this function_body_length
        addHeadline(channelViewModel.name.value)

        let labelStyle = Style.Label.headline
        let textStyle = Style.Label.body

        if let channel = channelViewModel.channel as? ForceClosingChannel {
            contentStackView.addArrangedElement(.horizontalStackView(compressionResistant: .first, content: [
                .label(text: L10n.Scene.ChannelDetail.ClosingTime.label + ":", style: labelStyle),
                .label(text: channel.blocksTilMaturityTimeString, style: textStyle)
            ]))
            contentStackView.addArrangedElement(.separator)
        }

        contentStackView.addArrangedElement(.verticalStackView(content: [
            .label(text: L10n.Scene.ChannelDetail.remotePubKeyLabel + ":", style: labelStyle),
            .label(text: channelViewModel.remotePubKey, style: textStyle)
        ], spacing: 0))

        if channelViewModel.state.value != ChannelState.waitingClose {
            contentStackView.addArrangedElement(.separator)
            let balanceView = ChannelBalanceView()
            balanceView.set(localBalance: channelViewModel.localBalance.value, remoteBalance: channelViewModel.remoteBalance.value)

            contentStackView.addArrangedElement(.verticalStackView(content: [
                .customHeight(10, element: .customView(balanceView)),
                .horizontalStackView(compressionResistant: .first, content: [
                    .customView(circleIndicatorView(gradient: UIColor.Zap.lightningOrangeGradient)),
                    .label(text: L10n.Scene.ChannelDetail.localBalanceLabel + ":", style: labelStyle),
                    .amountLabel(amount: channelViewModel.localBalance.value, style: textStyle)
                ]),
                .horizontalStackView(compressionResistant: .first, content: [
                    .customView(circleIndicatorView(gradient: UIColor.Zap.lightningBlueGradient)),
                    .label(text: L10n.Scene.ChannelDetail.remoteBalanceLabel + ":", style: labelStyle),
                    .amountLabel(amount: channelViewModel.remoteBalance.value, style: textStyle)
                ])
            ], spacing: 5))
        }

        contentStackView.addArrangedElement(.separator)
        let fundingTxId = channelViewModel.channelPoint.fundingTxid
        contentStackView.addArrangedElement(.horizontalStackView(compressionResistant: .first, content: [
            .label(text: L10n.Scene.ChannelDetail.fundingTransactionLabel + ":", style: labelStyle),
            .button(title: fundingTxId, style: Style.Button.custom(fontSize: 14)) { [weak self] _ in
                guard let self = self else { return }
                self.dismiss(animated: true, completion: {
                    self.presentBlockExplorer(fundingTxId, .transactionId)
                })
            }
        ]))

        if let closingTxId = channelViewModel.closingTxid.value {
            contentStackView.addArrangedElement(.separator)
            contentStackView.addArrangedElement(.horizontalStackView(compressionResistant: .first, content: [
                .label(text: L10n.Scene.ChannelDetail.closingTransactionLabel + ":", style: labelStyle),
                .button(title: closingTxId, style: Style.Button.custom(fontSize: 14)) { [weak self] _ in
                    guard let self = self else { return }
                    self.dismiss(animated: true, completion: {
                        self.presentBlockExplorer(closingTxId, .transactionId)
                    })
                }
            ]))
        }

        if channelViewModel.state.value == .active || channelViewModel.state.value == .inactive {
            let closeTitle = channelViewModel.state.value == .active ? L10n.Scene.ChannelDetail.closeButton : L10n.Scene.ChannelDetail.forceCloseButton

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
        guard let openChannel = channelViewModel.channel as? OpenChannel else { return }
        let alertController = UIAlertController.closeChannelAlertController(openChannel: openChannel, channelViewModel: channelViewModel) { [channelViewModel, weak self] in
            let loadingView = self?.presentLoadingView(text: L10n.Scene.Channels.closeLoadingView)
            self?.channelListViewModel.close(channelViewModel) { result in
                DispatchQueue.main.async {
                    self?.dismissAfterClose(result: result, loadingView: loadingView)
                }
            }
        }
        self.present(alertController, animated: true)
    }

    private func dismissAfterClose(result: Result<CloseStatusUpdate, LndApiError>, loadingView: LoadingView?) {
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

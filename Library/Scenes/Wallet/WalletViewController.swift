//
//  Library
//
//  Created by Otto Suess on 25.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning
import ReactiveKit
import SwiftBTC
import SwiftLnd

final class WalletViewController: UIViewController {
    // detail
    @IBOutlet private weak var detailView: UIView!
    @IBOutlet private weak var detailHandleView: ArrowHandleView!
    @IBOutlet private weak var segmentStackView: UIStackView!
    @IBOutlet private weak var circleGraphView: CircleGraphView!
    @IBOutlet private weak var segmentBackground: UIView!

    // header
    @IBOutlet private weak var networkLabel: PaddingLabel!
    @IBOutlet private weak var nodeAliasButton: UIButton!

    // send / receive buttons
    @IBOutlet private weak var bottomCurtain: UIView!
    @IBOutlet private weak var buttonContainerView: UIView!
    @IBOutlet private weak var sendButtonBackground: UIView!
    @IBOutlet private weak var receiveButtonBackground: UIView!
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var requestButton: UIButton!

    // balance view
    @IBOutlet private weak var totalBalanceLabel: UILabel!
    @IBOutlet private weak var swapIconImageView: UIImageView!
    @IBOutlet private weak var primaryBalanceLabel: UILabel!
    @IBOutlet private weak var secondaryBalanceLabel: UILabel!

    // sync view
    @IBOutlet private weak var syncBackgroundView: UIView!
    @IBOutlet private weak var syncViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var syncTitleLabel: UILabel!
    @IBOutlet private weak var syncProgressLabel: UILabel!
    @IBOutlet private weak var syncProgressView: UIProgressView!

    // swiftlint:disable implicitly_unwrapped_optional
    private var walletViewModel: WalletViewModel!
    private var sendButtonTapped: (() -> Void)!
    private var requestButtonTapped: (() -> Void)!
    private var nodeAliasButtonTapped: (() -> Void)!
    private var emptyStateViewModel: WalletEmptyStateViewModel!
    // swiftlint:enable implicitly_unwrapped_optional

    private let buttonCornerRadius: CGFloat = 20
    private var dragStartPosition: CGFloat = 0
    private var detailMaxOffset: CGFloat {
        return -(detailView.bounds.height - 45) - 60
    }

    static func instantiate(walletViewModel: WalletViewModel, sendButtonTapped: @escaping () -> Void, requestButtonTapped: @escaping () -> Void, nodeAliasButtonTapped: @escaping () -> Void, emptyStateViewModel: WalletEmptyStateViewModel) -> WalletViewController {
        let walletViewController = StoryboardScene.Wallet.walletViewController.instantiate()
        walletViewController.walletViewModel = walletViewModel

        walletViewController.sendButtonTapped = sendButtonTapped
        walletViewController.requestButtonTapped = requestButtonTapped
        walletViewController.nodeAliasButtonTapped = nodeAliasButtonTapped
        walletViewController.emptyStateViewModel = emptyStateViewModel

        walletViewController.tabBarItem.title = Tab.wallet.title
        walletViewController.tabBarItem.image = Tab.wallet.image

        return walletViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Scene.Wallet.title
        view.backgroundColor = UIColor.Zap.background

        Style.Button.custom().apply(to: sendButton, requestButton)

        requestButton.accessibilityIdentifier = "Request"
        UIView.performWithoutAnimation {
            sendButton.setTitle(L10n.Scene.Main.sendButton, for: .normal)
            sendButton.layoutIfNeeded()
            requestButton.setTitle(L10n.Scene.Main.receiveButton, for: .normal)
            requestButton.layoutIfNeeded()
        }

        Style.Label.body.apply(to: secondaryBalanceLabel, totalBalanceLabel)
        totalBalanceLabel.text = L10n.Scene.Wallet.totalBalance
        secondaryBalanceLabel.textColor = UIColor.Zap.gray
        secondaryBalanceLabel.textAlignment = .center
        Style.Label.boldTitle.apply(to: primaryBalanceLabel)
        primaryBalanceLabel.textAlignment = .center

        bottomCurtain.backgroundColor = UIColor.Zap.deepSeaBlue

        buttonContainerView.layer.cornerRadius = buttonCornerRadius
        buttonContainerView.clipsToBounds = true
        buttonContainerView.backgroundColor = UIColor.Zap.deepSeaBlue

        networkLabel.backgroundColor = UIColor.Zap.invisibleGray
        networkLabel.text = Network.testnet.localized

        sendButtonBackground.backgroundColor = UIColor.Zap.seaBlue
        receiveButtonBackground.backgroundColor = UIColor.Zap.seaBlue

        swapIconImageView.tintColor = UIColor.Zap.lightningOrange

        nodeAliasButton.setTitleColor(UIColor.Zap.gray, for: .normal)
        nodeAliasButton.titleLabel?.font = UIFont.Zap.regular

        setupPaddingLabel(networkLabel)
        setupPrimaryBalanceLabel()
        setupBindings()

        setupDetailView()
        setupSyncView()
        setupEmtpyState()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateDetailPosition()
    }

    private func setupEmtpyState() {
        let emptyStateView = EmptyStateView(viewModel: emptyStateViewModel)
        emptyStateView.add(to: view)

        walletViewModel.shouldHideEmptyWalletState
            .bind(to: emptyStateView.reactive.isHidden)
            .dispose(in: reactive.bag)
    }

    private func setupSyncView() {
        walletViewModel.syncViewModel.isSyncing
            .map { $0 ? UILayoutPriority(rawValue: 1) : UILayoutPriority(rawValue: 999) }
            .debounce(interval: 2)
            .observeOn(DispatchQueue.main)
            .observeNext { [weak self] in
                self?.syncViewHeightConstraint.priority = $0
                UIView.animate(withDuration: 0.25) {
                    self?.view.layoutIfNeeded()
                }
            }
            .dispose(in: reactive.bag)

        syncProgressView.trackTintColor = UIColor.Zap.deepSeaBlue

        walletViewModel.syncViewModel.percentSignal
            .map { Float($0) }
            .bind(to: syncProgressView.reactive.progress)
            .dispose(in: reactive.bag)

        walletViewModel.syncViewModel.percentSignal
            .map { "\(Int($0 * 100))%" }
            .bind(to: syncProgressLabel.reactive.text)
            .dispose(in: reactive.bag)

        syncTitleLabel.text = L10n.Scene.Sync.descriptionLabel

        syncBackgroundView.backgroundColor = UIColor.Zap.seaBlue

        Style.Label.body.apply(to: syncTitleLabel, syncProgressLabel)
    }

    private func setupPrimaryBalanceLabel() {
        ReactiveKit
            .combineLatest(walletViewModel.lightningService.balanceService.totalBalance, Settings.shared.primaryCurrency) { satoshis, currency -> NSAttributedString? in
                if let bitcoin = currency as? Bitcoin {
                    return bitcoin.attributedFormat(satoshis: satoshis)
                } else {
                    guard let string = currency.format(satoshis: satoshis) else { return nil }
                    return NSAttributedString(string: string)
                }
            }
            .distinctUntilChanged()
            .bind(to: primaryBalanceLabel.reactive.attributedText)
            .dispose(in: reactive.bag)
    }

    private func setupBindings() {
        [
            walletViewModel.lightningService.balanceService.totalBalance
                .distinctUntilChanged()
                .bind(to: secondaryBalanceLabel.reactive.text, currency: Settings.shared.secondaryCurrency),
            walletViewModel.circleGraphSegments
                .observeOn(DispatchQueue.main)
                .observeNext { [weak self] in
                    self?.circleGraphView.segments = $0
                },
            walletViewModel.network
                .ignoreNils()
                .map { $0.localized }
                .bind(to: networkLabel.reactive.text ),
            walletViewModel.network
                .map({ $0 == .mainnet })
                .bind(to: networkLabel.reactive.isHidden),
            walletViewModel.nodeAlias
                .bind(to: nodeAliasButton.reactive.title)
        ].dispose(in: reactive.bag)
    }

    private func setupPaddingLabel(_ paddingLabel: PaddingLabel) {
        paddingLabel.edgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        Style.Label.body.apply(to: paddingLabel)
        paddingLabel.layer.cornerRadius = 10
        paddingLabel.clipsToBounds = true
    }

    @IBAction private func presentSend(_ sender: Any) {
        sendButtonTapped()
    }

    @IBAction private func presentRequest(_ sender: Any) {
        requestButtonTapped()
    }

    @IBAction private func swapCurrencyButtonTapped(_ sender: Any) {
        Settings.shared.swapCurrencies()
    }

    @IBAction private func presentNodeList(_ sender: Any) {
        nodeAliasButtonTapped()
    }

    private func setupDetailView() {
        segmentStackView.clear()
        for segment in walletViewModel.balanceSegments {
            segmentStackView.addSegment(segment.segment, color: segment.segment.color, title: segment.segment.localized, amount: segment.amount)
        }

        segmentBackground.layer.cornerRadius = buttonCornerRadius

        circleGraphView.arcWidth = 6
        circleGraphView.emptyColor = UIColor.Zap.deepSeaBlue
    }

    private func updateDetailPosition() {
        if UserDefaults.Keys.walletDetailExpanded.get(defaultValue: false) {
            detailView.transform = CGAffineTransform(translationX: 0, y: detailMaxOffset)
            detailHandleView.progress = 1
        } else {
            detailView.transform = .identity
            detailHandleView.progress = 0
        }
    }

    @IBAction private func toggleDetailState() {
        if detailView.transform == .identity {
            animateDetail(expanded: true)
        } else if detailView.transform.ty == detailMaxOffset {
            animateDetail(expanded: false)
        }
    }

    @IBAction private func didPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let maxOffset = detailMaxOffset

        let yTranslation: CGFloat
        let newOffset = dragStartPosition + translation.y

        if newOffset < maxOffset {
            let additionalOffset = (newOffset - detailMaxOffset)
            yTranslation = maxOffset - pow(abs(additionalOffset), 0.85)
        } else {
            yTranslation = min(0, newOffset)
        }

        switch sender.state {
        case .possible:
            break
        case .began:
            dragStartPosition = detailView.transform.ty
        case .changed:
            detailView.transform = CGAffineTransform(translationX: 0, y: yTranslation)
            detailHandleView.progress = max(yTranslation, maxOffset) / maxOffset

        case .ended, .cancelled, .failed:
            let velocity = sender.velocity(in: view).y
            let triggerVelocity: CGFloat = 600

            if (yTranslation < maxOffset / 2 || velocity < -triggerVelocity) && velocity < triggerVelocity {
                animateDetail(expanded: true)
            } else {
                animateDetail(expanded: false)
            }
        @unknown default:
            break
        }
    }

    private func animateDetail(expanded: Bool) {
        let transform: CGAffineTransform
        let detailHandleViewProgress: CGFloat

        if expanded {
            transform = CGAffineTransform(translationX: 0, y: detailMaxOffset)
            detailHandleViewProgress = 1

            UserDefaults.Keys.walletDetailExpanded.set(true)
        } else {
            // bounce back
            transform = .identity
            detailHandleViewProgress = 0

            UserDefaults.Keys.walletDetailExpanded.set(false)
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.25, options: [], animations: { [detailView, detailHandleView] in
            detailView?.transform = transform
            detailHandleView?.progress = detailHandleViewProgress
        }, completion: nil)
    }
}

private extension Bitcoin {
    func attributedFormat(satoshis: Satoshi) -> NSAttributedString? {
        let formatter = SatoshiFormatter(unit: self)
        formatter.includeCurrencySymbol = false
        let amountString = formatter.string(from: satoshis) ?? "0"
        let attributedString = NSMutableAttributedString(string: amountString)
        attributedString.append(NSAttributedString(string: " " + symbol, attributes: [.font: UIFont.Zap.light]))
        return attributedString
    }
}

private extension UIStackView {
    func addSegment(_ segment: Segment, color: UIColor, title: String, amount: Signal<Satoshi, Never>) {
        let circleView = CircleView(frame: .zero)
        circleView.backgroundColor = .clear
        circleView.color = color

        let titleLabel = UILabel(frame: .zero)
        Style.Label.subHeadline.with({ $0.font = $0.font.withSize(17) }).apply(to: titleLabel)
        titleLabel.text = title

        let amountLabel = UILabel(frame: .zero)
        Style.Label.headline.apply(to: amountLabel)
        amountLabel.textAlignment = .right
        amount
            .bind(to: amountLabel.reactive.text, currency: Settings.shared.primaryCurrency)
            .dispose(in: reactive.bag)

        let horizontalStackView = UIStackView(arrangedSubviews: [circleView, titleLabel, amountLabel])
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 10

        NSLayoutConstraint.activate([
            circleView.widthAnchor.constraint(equalToConstant: 8)
        ])

        addArrangedSubview(horizontalStackView)

        if segment == .pending {
            amount
                .map { $0 <= 0 }
                .observeOn(DispatchQueue.main)
                .observeNext {
                    horizontalStackView.isHidden = $0
                }
                .dispose(in: reactive.bag)
        }
    }
}

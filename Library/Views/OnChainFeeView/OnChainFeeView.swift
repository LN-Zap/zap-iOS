//
//  Library
//
//  Created by 0 on 23.05.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Bond
import Foundation
import SwiftBTC
import SwiftLnd

protocol OnChainFeeViewDelegate: class {
    func confirmationTargetChanged(to confirmationTarget: Int)
    func didChangeSize(expanded: Bool)
}

final class OnChainFeeView: UIView {
    @IBOutlet private var contentView: UIView!

    @IBOutlet private weak var rightStackView: UIStackView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var deatiledDescriptionLabel: UILabel!
    @IBOutlet private weak var arrowImageView: UIImageView!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var timeIntervalLabel: UILabel!
    @IBOutlet private weak var bottomContainer: UIView!

    private let onChainFeeViewModel = OnChainFeeViewModel()

    var expanded = false {
        didSet {
            updateExpandedState(animated: true)
        }
    }

    weak var delegate: OnChainFeeViewDelegate?

    init(loadable: Observable<Loadable<Result<Satoshi, LoadingError>>>) {
        super.init(frame: .zero)
        setup(loadable: loadable)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup(loadable: Observable<Loadable<Result<Satoshi, LoadingError>>>) {
        Bundle.library.loadNibNamed("OnChainFeeView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        contentView.backgroundColor = UIColor.Zap.background

        Style.Label.headline.apply(to: titleLabel)
        Style.Label.subHeadline.apply(to: deatiledDescriptionLabel, timeIntervalLabel)

        let loadingAmountView = LoadingAmountView(loadable: loadable)
        loadingAmountView.textAlignment = .right

        let loadingAmountContainer = UIView()
        loadingAmountContainer.addAutolayoutSubview(loadingAmountView)
        NSLayoutConstraint.activate([
            loadingAmountContainer.topAnchor.constraint(equalTo: loadingAmountView.topAnchor),
            loadingAmountContainer.trailingAnchor.constraint(equalTo: loadingAmountView.trailingAnchor),
            loadingAmountContainer.bottomAnchor.constraint(equalTo: loadingAmountView.bottomAnchor)
        ])

        rightStackView.insertArrangedSubview(loadingAmountContainer, at: 0)

        titleLabel.text = L10n.Scene.Send.OnChain.fee

        updateFeeLabels(for: 0)

        for (index, title) in onChainFeeViewModel.titles.enumerated() {
            segmentedControl.setTitle(title, forSegmentAt: index)
        }

        updateExpandedState(animated: false)
    }

    @IBAction private func toggleDetail(_ sender: Any) {
        expanded.toggle()
        updateExpandedState(animated: true)
        delegate?.didChangeSize(expanded: expanded)
    }

    private func updateExpandedState(animated: Bool) {
        let asset = expanded ? Asset.iconArrowUpSmall : Asset.iconArrowDownSmall
        arrowImageView.image = asset.image

        if animated {
            layoutIfNeeded()
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self = self else { return }
                self.bottomContainer.isHidden = !self.expanded
                self.layoutIfNeeded()
            }
        } else {
            bottomContainer.isHidden = !expanded
        }
    }

    @IBAction private func updateSegment(_ sender: UISegmentedControl) {
        updateFeeLabels(for: sender.selectedSegmentIndex)

        let confirmationTarget = onChainFeeViewModel.tiers[sender.selectedSegmentIndex].confirmationTarget
        delegate?.confirmationTargetChanged(to: confirmationTarget)
    }

    private func updateFeeLabels(for index: Int) {
        let tier = onChainFeeViewModel.tiers[index]
        timeIntervalLabel.text = L10n.Scene.Send.OnChain.Fee.estimatedDelivery(tier.formattedConfirmationTimeInterval)
        deatiledDescriptionLabel.text = tier.description
    }
}

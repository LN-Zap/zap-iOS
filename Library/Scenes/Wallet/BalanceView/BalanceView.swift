//
//  Library
//
//  Created by 0 on 14.11.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import SwiftBTC

final class BalanceView: UIView {
    @IBOutlet private weak var totalBalanceLabel: UILabel!
    @IBOutlet private weak var largeAmountView: LargeAmountView!
    @IBOutlet private weak var secondaryBalanceLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        Style.Label.body.apply(to: secondaryBalanceLabel, totalBalanceLabel)
        totalBalanceLabel.text = L10n.Scene.Wallet.totalBalance
        secondaryBalanceLabel.textColor = UIColor.Zap.gray
        secondaryBalanceLabel.textAlignment = .center
    }
    
    func setup(totalBalance: Observable<Satoshi>) {
        largeAmountView.value = totalBalance
        
        totalBalance
            .removeDuplicates()
            .bind(to: secondaryBalanceLabel.reactive.text, currency: Settings.shared.secondaryCurrency)
            .dispose(in: reactive.bag)
    }
    
    private func setup() {
        let views = Bundle.library.loadNibNamed("BalanceView", owner: self, options: nil)
        guard let content = views?.first as? UIView else { return }

        addAutolayoutSubview(content)

        content.backgroundColor = UIColor.Zap.background
        
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: bottomAnchor),
            content.leadingAnchor.constraint(equalTo: leadingAnchor),
            content.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

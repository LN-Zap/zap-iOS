//
//  Zap
//
//  Created by Otto Suess on 03.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import SwiftBTC
import UIKit

final class BalanceView: UIView {

    private weak var localBalanceView: UIView?

    func set(localBalance: Satoshi, remoteBalance: Satoshi) {
        backgroundColor = UIColor.Zap.white

        layer.cornerRadius = 5
        clipsToBounds = true

        let localBalanceView = GradientView(frame: CGRect.zero)

        addAutolayoutSubview(localBalanceView)

        let multiplier = CGFloat(truncating: localBalance / (localBalance + remoteBalance) as NSDecimalNumber)

        NSLayoutConstraint.activate([
            localBalanceView.leadingAnchor.constraint(equalTo: leadingAnchor),
            localBalanceView.bottomAnchor.constraint(equalTo: bottomAnchor),
            localBalanceView.topAnchor.constraint(equalTo: topAnchor),
            localBalanceView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: multiplier)
        ])

        self.localBalanceView = localBalanceView
    }
}

//
//  Zap
//
//  Created by Otto Suess on 03.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import SwiftBTC
import UIKit

final class ChannelBalanceView: UIView {

    private weak var localBalanceView: UIView?

    func set(localBalance: Satoshi, remoteBalance: Satoshi) {
        layer.cornerRadius = 5
        clipsToBounds = true

        let localBalanceView = GradientView(frame: CGRect.zero)
        addAutolayoutSubview(localBalanceView)

        let remoteBalanceView = GradientView(frame: CGRect.zero)
        remoteBalanceView.gradient = UIColor.Zap.lightningBlueGradient
        addAutolayoutSubview(remoteBalanceView)

        let multiplier = CGFloat(truncating: localBalance / (localBalance + remoteBalance) as NSDecimalNumber)

        NSLayoutConstraint.activate([
            localBalanceView.leadingAnchor.constraint(equalTo: leadingAnchor),
            localBalanceView.bottomAnchor.constraint(equalTo: bottomAnchor),
            localBalanceView.topAnchor.constraint(equalTo: topAnchor),
            localBalanceView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: multiplier),

            remoteBalanceView.leadingAnchor.constraint(equalTo: localBalanceView.trailingAnchor),
            remoteBalanceView.bottomAnchor.constraint(equalTo: bottomAnchor),
            remoteBalanceView.topAnchor.constraint(equalTo: topAnchor),
            remoteBalanceView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        self.localBalanceView = localBalanceView
    }
}

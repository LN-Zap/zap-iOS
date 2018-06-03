//
//  Zap
//
//  Created by Otto Suess on 03.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import UIKit

class BalanceView: UIView {

    private weak var localBalanceView: UIView?
    
    func set(localBalance: Satoshi, remoteBalance: Satoshi) {
        backgroundColor = UIColor.zap.searchBackground
        
        layer.cornerRadius = 5
        clipsToBounds = true
        
        let localBalanceView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        localBalanceView.translatesAutoresizingMaskIntoConstraints = false
        localBalanceView.backgroundColor = UIColor.zap.green
        self.addSubview(localBalanceView)
        
        let multiplier = CGFloat(truncating: localBalance / (localBalance + remoteBalance))
        
        NSLayoutConstraint.activate([
            localBalanceView.leadingAnchor.constraint(equalTo: leadingAnchor),
            localBalanceView.bottomAnchor.constraint(equalTo: bottomAnchor),
            localBalanceView.topAnchor.constraint(equalTo: topAnchor),
            localBalanceView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: multiplier)
        ])

        self.localBalanceView = localBalanceView
    }
}

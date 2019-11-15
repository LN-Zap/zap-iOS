//
//  Library
//
//  Created by 0 on 14.11.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Bond
import Foundation

final class CurrencySwitchLabel: PaddingLabel {
    private let minSize: CGFloat = 24
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        edgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        edgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        invalidateIntrinsicContentSize()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.Zap.seaBlue
        
        textColor = UIColor.Zap.lightningOrange
        font = .systemFont(ofSize: 17, weight: .medium)
        textAlignment = .center
        setContentCompressionResistancePriority(.required, for: .horizontal)
        
        Settings.shared.primaryCurrency
            .map { $0.symbol }
            .bind(to: reactive.text)
            .dispose(in: reactive.bag)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: minSize),
            widthAnchor.constraint(greaterThanOrEqualToConstant: minSize)
        ])
        
        layer.cornerRadius = 5
        layer.masksToBounds = true
    }
}

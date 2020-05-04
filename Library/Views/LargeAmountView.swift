//
//  Library
//
//  Created by 0 on 15.11.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import SwiftBTC

final class LargeAmountView: UIView {
    private weak var label: UILabel! // swiftlint:disable:this implicitly_unwrapped_optional
    
    var value: Observable<Satoshi>? {
        didSet {
            guard let value = value else { return }
            
            combineLatest(value, Settings.shared.primaryCurrency) { satoshis, currency -> String? in
                currency.format(satoshis: satoshis, includeSymbol: false)
            }
            .removeDuplicates()
            .bind(to: label.reactive.text)
            .dispose(in: reactive.bag)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        
        let spacerView = UIView()
        spacerView.backgroundColor = .clear
        
        let label = UILabel()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        Style.Label.largeAmount.apply(to: label)

        let currencySwitchContainer = UIView()
        currencySwitchContainer.backgroundColor = .clear
        
        let currencySwitchLabel = CurrencySwitchLabel()
        currencySwitchContainer.addAutolayoutSubview(currencySwitchLabel)
        
        let stackView = UIStackView(arrangedSubviews: [
            spacerView,
            label,
            currencySwitchContainer
        ])
        stackView.spacing = 5
        stackView.axis = .horizontal
        
        addAutolayoutSubview(stackView)
        stackView.constrainEdges(to: self)
        
        NSLayoutConstraint.activate([
            currencySwitchLabel.leadingAnchor.constraint(equalTo: currencySwitchContainer.leadingAnchor),
            currencySwitchLabel.trailingAnchor.constraint(equalTo: currencySwitchContainer.trailingAnchor),
            label.firstBaselineAnchor.constraint(equalTo: currencySwitchLabel.firstBaselineAnchor),
            spacerView.widthAnchor.constraint(equalTo: currencySwitchContainer.widthAnchor)
        ])
        
        let button = UIButton(type: .system)
        button.setTitle(nil, for: .normal)
        button.addTarget(self, action: #selector(swapCurrencyButtonTapped(_:)), for: .touchUpInside)
        addAutolayoutSubview(button)
        button.constrainEdges(to: self)
        
        self.label = label
    }
    
    @objc private func swapCurrencyButtonTapped(_ sender: Any) {
        Settings.shared.swapCurrencies()
    }
}

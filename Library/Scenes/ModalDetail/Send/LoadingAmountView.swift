//
//  Library
//
//  Created by Otto Suess on 26.10.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import SwiftBTC

enum Loadable<E> {
    case loading
    case element(E)
}

final class LoadingAmountView: UIView {
    let amountLabel: UILabel
    let activityIndicator: UIActivityIndicatorView
    var disposable: Disposable?
    
    init(loadable: Observable<Loadable<Satoshi?>>) {
        amountLabel = UILabel(frame: CGRect.zero)
        activityIndicator = UIActivityIndicatorView(style: .white)
        
        super.init(frame: CGRect.zero)
        
        addAutolayoutSubview(amountLabel)
        addAutolayoutSubview(activityIndicator)
        activityIndicator.startAnimating()
        Style.Label.footnote.apply(to: amountLabel)
        
        NSLayoutConstraint.activate([
            amountLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            amountLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            activityIndicator.leadingAnchor.constraint(equalTo: leadingAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        updateLoadable(loadable.value)
        
        loadable
            .observeOn(DispatchQueue.main)
            .observeNext { [weak self] loadable in
                self?.updateLoadable(loadable)
            }
            .dispose(in: reactive.bag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateLoadable(_ loadable: Loadable<Satoshi?>) {
        switch loadable {
        case .loading:
            activityIndicator.isHidden = false
            amountLabel.isHidden = true
        case .element(let amount):
            disposable?.dispose()
            amountLabel.isHidden = false
            activityIndicator.isHidden = true
            
            if let amount = amount {
                disposable = amount
                    .bind(to: amountLabel, currency: Settings.shared.primaryCurrency)
                disposable?.dispose(in: reactive.bag)
            } else {
                amountLabel.text = "-"
            }
            
        }
        
    }
}

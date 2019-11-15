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
import SwiftLnd

enum Loadable<E> {
    case loading
    case element(E)
}

enum LoadingError: Error {
    case invalidAmount
    case lndApiError(LndApiError)
}

final class LoadingAmountView: UIView {
    let amountLabel: UILabel
    let activityIndicator: UIActivityIndicatorView
    var disposable: Disposable?

    var textAlignment: NSTextAlignment {
        get {
            return amountLabel.textAlignment
        }
        set {
            amountLabel.textAlignment = newValue
        }
    }

    init(loadable: Observable<Loadable<Result<Satoshi, LoadingError>>>) {
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
            amountLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            activityIndicator.leadingAnchor.constraint(equalTo: leadingAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: trailingAnchor),
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

    private func updateLoadable(_ loadable: Loadable<Result<Satoshi, LoadingError>>) {
        switch loadable {
        case .loading:
            activityIndicator.isHidden = false
            amountLabel.isHidden = true
        case .element(let result):
            disposable?.dispose()
            amountLabel.isHidden = false
            activityIndicator.isHidden = true
            
            switch result {
            case .success(let amount):
                disposable = amount
                    .bind(to: amountLabel, currency: Settings.shared.primaryCurrency)
                disposable?.dispose(in: reactive.bag)
            case .failure:
                amountLabel.text = "-"
            }
        }
    }
}

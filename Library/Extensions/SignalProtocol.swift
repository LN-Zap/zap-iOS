//
//  Zap
//
//  Created by Otto Suess on 31.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import BTCUtil
import Foundation
import ReactiveKit

extension SignalProtocol where Element == Satoshi?, Error == NoError {
    // Bind Satoshi? signal with Currency to any bindable String?.
    func bind<B: BindableProtocol>(to bindable: B, currency: Observable<Currency>) -> Disposable where B.Element == String? {
        return ReactiveKit
            .combineLatest(self, currency) { satoshis, currency -> String? in
                if let satoshis = satoshis {
                    return currency.format(satoshis: satoshis)
                } else {
                    return nil
                }
            }
            .bind(to: bindable)
    }
}

extension SignalProtocol where Element == Satoshi, Error == NoError {
    // Bind Satoshi signal with Currency to any bindable String?.
    func bind<B: BindableProtocol>(to bindable: B, currency: Observable<Currency>) -> Disposable where B.Element == String? {
        return ReactiveKit
            .combineLatest(self, currency) { satoshis, currency -> String? in
                currency.format(satoshis: satoshis)
            }
            .bind(to: bindable)
    }
}

extension Satoshi {
    func bind<B: BindableProtocol>(to bindable: B, currency: Observable<Currency>) -> Disposable where B.Element == String? {
        return Observable<Satoshi?>(self)
            .bind(to: bindable, currency: currency)
    }

}

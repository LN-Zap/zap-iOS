//
//  Library
//
//  Created by Otto Suess on 22.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit

protocol ProductCell {
    // swiftlint:disable implicitly_unwrapped_optional
    var countLabel: UILabel! { get }
    var nameLabel: UILabel! { get }
    var priceLabel: UILabel! { get }
    // swiftlint:enable implicitly_unwrapped_optional
    var onReuseBag: DisposeBag { get }
    
    func setItem(product: Product, count: Observable<Int>)
}

extension ProductCell {
    func setItem(product: Product, count: Observable<Int>) {
        nameLabel.text = product.name
        priceLabel.text = "\(product.price)"
        
        count
            .map { $0 <= 0 }
            .bind(to: countLabel.reactive.isHidden)
            .dispose(in: onReuseBag)
        
        count
            .map { String($0) }
            .bind(to: countLabel.reactive.text)
            .dispose(in: onReuseBag)
    }
}

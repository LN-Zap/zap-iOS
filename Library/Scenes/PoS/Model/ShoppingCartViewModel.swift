//
//  Library
//
//  Created by Otto Suess on 20.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

final class SelectedItem {
    var count: Int
    let product: Product
    
    var sum: Decimal {
        return Decimal(count) * product.price
    }
    
    init(count: Int, product: Product) {
        self.count = count
        self.product = product
    }
}

final class ShoppingCartViewModel {
    var items = [SelectedItem]()
    
    var itemCount: Int {
        return items.reduce(0) { $0 + $1.count }
    }
    
    var sum: Decimal {
        return items.reduce(0) { $0 + $1.sum }
    }
    
    func count(of product: Product) -> Int {
        return item(of: product)?.count ?? 0
    }
    
    func addSingle(product: Product) {
        if let item = item(of: product) {
            item.count += 1
        } else {
            items.append(SelectedItem(count: 1, product: product))
        }
    }
    
    func removeSingle(product: Product) {
        guard let item = item(of: product) else { return }
        item.count -= 1
        
        if item.count == 0 { // swiftlint:disable:this empty_count
            items.removeAll { $0.product == product }
        }
    }
    
    func remove(at index: Int) {
        items.remove(at: index)
    }
    
    func removeAll() {
        items.removeAll()
    }
    
    private func item(of product: Product) -> SelectedItem? {
        return items.first(where: { $0.product == product })
    }
}

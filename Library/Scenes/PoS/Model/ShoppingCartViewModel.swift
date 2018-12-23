//
//  Library
//
//  Created by Otto Suess on 20.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

final class ShoppingCartViewModel {
    init(productsViewModel: ProductsViewModel) {
        items = [Product: Observable<Int>]()
        for product in productsViewModel.allProducts {
            items[product] = Observable(0)
        }
    }
    
    private var items = [Product: Observable<Int>]()
    
    var itemCount: Int {
        return items.values.reduce(0) { $0 + $1.value }
    }
    
    var sum: Decimal {
        return items.reduce(0) { $0 + $1.key.price * Decimal($1.value.value) }
    }
    
    var selectedItems: [(Product, Observable<Int>)] {
        return items
            .filter { $0.1.value > 0 }
            .map { ($0.key, $0.value) }
    }
    
    func count(of product: Product) -> Observable<Int> {
        return items[product] ?? Observable(0)
    }
    
    func addSingle(product: Product) {
        items[product]?.value += 1
    }
    
    func removeSingle(product: Product) {
        guard count(of: product).value > 0 else { return }
        items[product]?.value -= 1
    }
    
    func removeAll(product: Product) {
        items[product]?.value = 0
    }
    
    func removeAll() {
        for product in items.keys {
            items[product]?.value = 0
        }
    }
}

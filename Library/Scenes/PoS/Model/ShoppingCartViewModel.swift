//
//  Library
//
//  Created by Otto Suess on 20.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

final class ShoppingCartViewModel {
    let totalAmount: Observable<Decimal>
    let totalCount: Observable<Int>
    
    init(productsViewModel: ProductsViewModel) {
        items = [Product: Observable<Int>]()
        for product in productsViewModel.allProducts {
            items[product] = Observable(0)
        }
        
        totalAmount = Observable(0)
        totalCount = Observable(0)
        
        load()
    }
    
    private var items = [Product: Observable<Int>]()
    
    var persistable: [Product: Int] {
        return items.mapValues { $0.value }
    }
    
    var itemCount: Int {
        return items.values.reduce(0) { $0 + $1.value }
    }
    
    private var sum: Decimal {
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
    
    func setCount(of product: Product, to count: Int) {
        UISelectionFeedbackGenerator().selectionChanged()

        items[product]?.value = count
        update()
    }
    
    func addSingle(product: Product) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        items[product]?.value += 1
        update()
    }
    
    func removeSingle(product: Product) {
        guard count(of: product).value > 0 else { return }
        items[product]?.value -= 1
        update()
    }
    
    func removeAll(product: Product) {
        items[product]?.value = 0
        update()
    }
    
    func removeAll() {
        for product in items.keys {
            items[product]?.value = 0
        }
        update()
    }
    
    private func updateAmount() {
        totalAmount.value = sum
        totalCount.value = itemCount
    }
    
    private func update() {
        updateAmount()
        save()
    }
    
    private func save() {
        Storage.store(persistable, to: "ShoppingCart")
    }
    
    private func load() {
        guard let persistable: [Product: Int] = Storage.restore("ShoppingCart") else { return }
        
        for (key, value) in persistable {
            items[key]?.value = value
        }
        
        updateAmount()
    }
}

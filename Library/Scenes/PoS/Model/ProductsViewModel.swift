//
//  Library
//
//  Created by Otto Suess on 21.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

typealias JSON = [String: Any]

final class ProductsViewModel {
    let favourites: [[Product]]
    let productGroup: Group
    
    var allProducts: Set<Product> {
        return Set(favourites.flatMap { $0 } + groupedProducts(group: productGroup))
    }
    
    init() {
        guard
            let path = Bundle.library.path(forResource: "pos", ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? JSON ?? [:],
            let jsonFavourites = json["favorites"] as? [[JSON]],
            let jsonProducts = json["products"] as? [JSON],
            let memo = json["memo"] as? String
            else { fatalError("invalid pos json") }
        
        favourites = jsonFavourites.compactMap { $0.compactMap(Product.init) }
        let products = jsonProducts.compactMap(decodeGroupable)
        productGroup = Group(name: "All Items", items: products)
        
        UserDefaults.Keys.posMemo.set(memo)
    }
    
    private func groupedProducts(group: Group) -> [Product] {
        var result = [Product]()
        for item in group.items {
            if let product = item as? Product {
                result.append(product)
            } else if let group = item as? Group {
                result += groupedProducts(group: group)
            }
        }
        return result
    }
}

private func decodeGroupable(json: JSON) -> Groupable? {
    return Product(json: json) ?? Group(json: json)
}

private extension Product {
    init?(json: JSON) {
        guard
            let name = json["name"] as? String,
            let price = json["price"] as? Double
            else { return nil }
        self.name = name
        self.price = Decimal(price)
    }
}

private extension Group {
    init?(json: JSON) {
        guard
            let name = json["name"] as? String,
            let items = json["items"] as? [JSON]
            else { return nil }
        self.name = name
        self.items = items.compactMap(decodeGroupable)
    }
}

//
//  Library
//
//  Created by Otto Suess on 21.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

final class ProductsViewModel {
    let favourites: [Product] = [
        Product(name: "Bier", price: 3.50),
        Product(name: "Bier 2", price: 2.75),
        Product(name: "Pils", price: 1.30),
        Product(name: "TS 1", price: 0.01),
        Product(name: "TS 2", price: 5),
        Product(name: "TS 3", price: 1),
        Product(name: "TS 21", price: 2),
        Product(name: "TS 22", price: 100),
        Product(name: "TS 23", price: 15)
    ]
    
    let products: [Groupable] = [
        Group(name: "N/A Bevs", items: [
            Product(name: "TS 3", price: 1),
            Product(name: "TS 21", price: 2),
            Product(name: "TS 22", price: 100),
            Product(name: "TS 23", price: 15)
        ]),
        Group(name: "Vodka", items: [
            Product(name: "TS 3", price: 1),
            Product(name: "TS 21", price: 2),
            Product(name: "TS 22", price: 100),
            Product(name: "TS 23", price: 15)
        ]),
        Group(name: "Gin", items: [
            Product(name: "TS 3", price: 1),
            Product(name: "TS 21", price: 2),
            Product(name: "TS 22", price: 100),
            Product(name: "TS 23", price: 15)
        ]),
        Group(name: "Rum", items: [
            Product(name: "TS 3", price: 1),
            Product(name: "TS 21", price: 2),
            Product(name: "TS 22", price: 100),
            Product(name: "TS 23", price: 15)
        ]),
        Group(name: "Bourbon", items: [
            Product(name: "TS 3", price: 1),
            Product(name: "TS 21", price: 2),
            Product(name: "TS 22", price: 100),
            Product(name: "TS 23", price: 15)
        ]),
        Group(name: "Whiskey", items: [
            Product(name: "TS 3", price: 1),
            Product(name: "TS 21", price: 2),
            Product(name: "TS 22", price: 100),
            Product(name: "TS 23", price: 15)
        ])
    ]
}

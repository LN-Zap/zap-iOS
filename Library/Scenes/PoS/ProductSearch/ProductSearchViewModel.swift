//
//  Library
//
//  Created by Otto Suess on 23.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

final class ProductSearchViewModel {
    private let group: Group
    let items: MutableObservableArray<Groupable>
    var title: String {
        return group.name
    }
    
    var searchString: String? = nil {
        didSet {
            if let searchString = searchString, !searchString.isEmpty {
                items.replace(with: searchProducts(in: group, string: searchString))
            } else {
                items.replace(with: group.items)
            }
        }
    }
    
    func searchProducts(in group: Group, string: String) -> [Groupable] {
        var result = [Groupable]()
        
        for item in group.items {
            if let group = item as? Group {
                result += searchProducts(in: group, string: string)
            } else if let item = item as? Product,
                matches(groupable: item, string: string) {
                result.append(item)
            }
        }
        
        return result
    }
    
    func matches(groupable: Groupable, string: String) -> Bool {
        return groupable.name.localizedLowercase.contains(string.localizedLowercase)
    }
    
    init(group: Group) {
        self.group = group
        items = MutableObservableArray(group.items)
    }
}

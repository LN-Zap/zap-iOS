//
//  Lightning
//
//  Created by 0 on 03.04.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Bond
import Foundation
import SwiftLnd

protocol ListUpdater {
    func update()
}

protocol GenericListUpdater: ListUpdater {
    associatedtype Item

    var items: MutableObservableArray<Item> { get }
}

protocol IdentityProviding {
    var id: String { get }
}

extension Transaction: IdentityProviding {}
extension Invoice: IdentityProviding {}
extension Payment: IdentityProviding {}

extension GenericListUpdater where Item: IdentityProviding {
    @discardableResult func appendOrReplace(_ transaction: Item) -> Bool {
        var isNew = true
        items.batchUpdate {
            for (index, item) in $0.array.enumerated() where item.id == transaction.id {
                $0.remove(at: index)
                isNew = false
                break
            }
            $0.append(transaction)
        }
        return isNew
    }
}

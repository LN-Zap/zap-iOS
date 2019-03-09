import Bond
import Foundation

extension Array2DElement where Section: Equatable, Item: Equatable {
    static func areElementsEqual(one: Array2DElement<Section, Item>, two: Array2DElement<Section, Item>) -> Bool {
        return one.section == two.section && one.item == two.item
    }
}

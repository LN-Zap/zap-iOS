import Bond
import Foundation

extension Array2D where Item: Equatable {
    static func areEqual(left: Array2D<SectionMetadata, Item>.Node, right: Array2D<SectionMetadata, Item>.Node) -> Bool {
        return left.item == right.item
    }
}

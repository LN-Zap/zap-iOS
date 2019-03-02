import Bond

public func to2DArraySection<T, U>(section: T, items: [U]) -> TreeNode<Array2DElement<T, U>> {
    let section = Array2DElement<T, U>.section(section)
    return TreeNode(section, items.map {
        TreeNode(Array2DElement<T, U>.item($0))
    })
}

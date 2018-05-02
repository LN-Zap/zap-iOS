//
//  Zap
//
//  Created by Otto Suess on 23.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

extension UICollectionView {
    func registerCell(_ type: UICollectionViewCell.Type) {
        register(UINib(nibName: String(describing: type), bundle: nil), forCellWithReuseIdentifier: String(describing: type))
    }
    
    func dequeueCellForIndexPath<T: UICollectionViewCell>(_ indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("\(String(describing: T.self)) cell could not be instantiated because it was not found on the tableView")
        }
        return cell
    }
}

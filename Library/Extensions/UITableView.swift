//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

extension UITableView {
    func registerCell(_ type: UITableViewCell.Type) {
        register(UINib(nibName: String(describing: type), bundle: Bundle.shared), forCellReuseIdentifier: String(describing: type))
    }
    
    func dequeueCellForIndexPath<T: UITableViewCell>(_ indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("\(String(describing: T.self)) cell could not be instantiated because it was not found on the tableView")
        }
        return cell
    }
}

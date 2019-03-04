//
//  Library
//
//  Created by Otto Suess on 19.02.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

protocol Coordinator {
    var rootViewController: RootViewController { get }

    func start()
}

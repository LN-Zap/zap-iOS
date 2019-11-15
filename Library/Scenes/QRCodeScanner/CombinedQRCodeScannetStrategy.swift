//
//  Library
//
//  Created by 0 on 08.11.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

final class CombinedQRCodeScannetStrategy: QRCodeScannerStrategy {
    var title: String {
        return strategies[0].title
    }
    
    var pasteButtonTitle: String {
        return strategies[0].pasteButtonTitle
    }

    let strategies: [QRCodeScannerStrategy]
    
    init(strategies: [QRCodeScannerStrategy]) {
        self.strategies = strategies
    }
    
    func viewControllerForAddress(address: String, completion: @escaping (Result<UIViewController, QRCodeScannerStrategyError>) -> Void) {
        firstViewController(strategies: strategies, address: address, completion: completion)
    }
    
    func firstViewController(strategies: [QRCodeScannerStrategy], address: String, completion: @escaping (Result<UIViewController, QRCodeScannerStrategyError>) -> Void) {
        var strategies = Array(strategies.reversed())
        if let strategy = strategies.popLast() {
            strategy.viewControllerForAddress(address: address) { [weak self] result in
                switch result {
                case .success:
                    completion(result)
                case .failure:
                    if strategies.isEmpty {
                        completion(result)
                    } else {
                        self?.firstViewController(strategies: strategies, address: address, completion: completion)
                    }
                }
            }
        }
    }
}

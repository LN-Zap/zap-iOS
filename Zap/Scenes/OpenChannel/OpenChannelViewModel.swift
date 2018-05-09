//
//  Zap
//
//  Created by Otto Suess on 10.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

final class OpenChannelViewModel {
    private let viewModel: ViewModel
    private let pubKey: String
    private let host: String
    
    var amount: Satoshi = 0
    
    init?(viewModel: ViewModel, address: String) {
        self.viewModel = viewModel
        
        let addressComponents = address.split { ["@", " "].contains(String($0)) }
        guard addressComponents.count == 2 else { return nil }
        
        pubKey = String(addressComponents[0])
        host = String(addressComponents[1])        
    }
    
    func openChannel(completion: @escaping () -> Void) {
        viewModel.connect(pubKey: pubKey, host: host) { [pubKey, viewModel, amount] result in
//            guard result.error == nil else { return } // TODO: error handling
            viewModel.openChannel(pubKey: pubKey, amount: amount, completion: completion)
        }
    }
}

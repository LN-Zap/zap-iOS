//
//  Zap
//
//  Created by Otto Suess on 10.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

//import BTCUtil
import Foundation

final class OpenChannelViewModel {
    private let viewModel: ViewModel
    private let pubKey: String
    private let host: String
    
    init?(viewModel: ViewModel, address: String) {
        self.viewModel = viewModel
        
        let addressComponents = address.split { ["@", " "].contains(String($0)) }
        guard addressComponents.count == 2 else { return nil }
        
        pubKey = String(addressComponents[0])
        host = String(addressComponents[1])
    }
    
    func openChannel() {
        viewModel.connect(pubKey: pubKey, host: host) { [pubKey, viewModel] _ in
            _ = viewModel.openChannel(pubKey: pubKey, amount: 1000000)
        }
    }
}

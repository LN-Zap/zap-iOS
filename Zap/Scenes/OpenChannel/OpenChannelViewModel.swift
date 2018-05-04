//
//  Zap
//
//  Created by Otto Suess on 10.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

final class OpenChannelViewModel: AmountInputtable {
    private let minChannelSize: Satoshi = 20000
    private let maxChannelSize: Satoshi = 16777216
    
    let amountString: Observable<String?>
    let isAmountValid: Observable<Bool>
    
    private let viewModel: ViewModel
    private let pubKey: String
    private let host: String
    
    private var satoshis: Satoshi {
        guard let amountString = amountString.value else { return 0 }
        return Satoshi.from(string: amountString, unit: .bit) ?? 0
    }
    
    init?(viewModel: ViewModel, address: String) {
        self.viewModel = viewModel
        
        let addressComponents = address.split { ["@", " "].contains(String($0)) }
        guard addressComponents.count == 2 else { return nil }
        
        pubKey = String(addressComponents[0])
        host = String(addressComponents[1])
        
        amountString = Observable("")
        isAmountValid = Observable(true)
    }
    
    func openChannel() {
        viewModel.connect(pubKey: pubKey, host: host) { [pubKey, viewModel, satoshis] result in
            guard result.error == nil else { return } // TODO: error handling
            viewModel.openChannel(pubKey: pubKey, amount: satoshis)
        }
    }
    
    func updateAmount(_ amount: String?) {
        amountString.value = amount
        if amount != nil {
            isAmountValid.value = satoshis >= minChannelSize && satoshis <= maxChannelSize
        }
    }
}

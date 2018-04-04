//
//  Zap
//
//  Created by Otto Suess on 10.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation

final class OpenChannelViewModel {
    private let viewModel: ViewModel
    var address: String?
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    static private func connectAndOpenChannel(viewModel: ViewModel, lightningAddress: String, amount: Satoshi) {
        let addressComponents = lightningAddress.split { ["@", " "].contains(String($0)) }
        guard addressComponents.count == 2 else { return } // TODO show Error
        
        let pubKey = String(addressComponents[0])
        let host = String(addressComponents[1])
     
        viewModel.connect(pubKey: pubKey, host: host) { _ in
            _ = viewModel.openChannel(pubKey: pubKey, amount: amount)
        }
    }
    
    func open() {
        //            guard let amountString = amountString else { return Observable<Void>.empty() }
        //            let amount = Settings.bitcoinUnit
        //                .map { $0.satoshis(string: amountString) }
        //                .filterNil()
        //
        //            return Observable.combineLatest(amount, address)
        //                .flatMap { tuple -> Observable<OpenStatusUpdate> in
        //                    let (amount, address) = tuple
        //                    OpenChannelViewModel.connectAndOpenChannel(viewModel: viewModel, lightningAddress: address, amount: amount)

    }
    
    func paste() {
        if let string = UIPasteboard.general.string {
            address = string
        }
    }
}

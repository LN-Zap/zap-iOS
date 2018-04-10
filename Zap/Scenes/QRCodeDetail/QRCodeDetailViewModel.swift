//
//  Zap
//
//  Created by Otto Suess on 07.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Foundation

enum Loading<Value> {
    case value(Value)
    case loading
    
    var value: Value? {
        switch self {
        case let .value(value):
            return value
        case .loading:
            return nil
        }
    }
}

protocol QRCodeDetailViewModel {
    var title: String { get }
    var address: Observable<Loading<String>> { get }
}

final class OnChainRequestQRCodeViewModel: QRCodeDetailViewModel {
    let title = "scene.deposit.title".localized
    let address: Observable<Loading<String>>

    init(viewModel: ViewModel) {
        address = Observable(.loading)
        viewModel.newAddress { [address] result in
            guard let addressString = result.value else { return }
            address.value = .value(addressString)
        }
    }
}

final class LightningRequestQRCodeViewModel: QRCodeDetailViewModel {
    let title = "scene.request.title".localized
    let address: Observable<Loading<String>>

    init(paymentRequest: String) {
        self.address = Observable(.value(paymentRequest))
    }
}

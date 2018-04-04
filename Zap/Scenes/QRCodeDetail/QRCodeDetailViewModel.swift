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

final class DepositViewModel: QRCodeDetailViewModel {
    let title = "scene.deposit.title".localized
    var address: Observable<Loading<String>>

    init(viewModel: ViewModel) {
        address = Observable(.loading)
        viewModel.newAddress { [weak self] result in
            guard let address = result.value else { return }
            self?.address.value = .value(address)
        }
    }
}

final class ReceiveViewModel: QRCodeDetailViewModel {
    let title = "scene.receive.title".localized
    var address: Observable<Loading<String>>

    init(paymentRequest: String) {
        self.address = Observable(.value(paymentRequest))
    }
}

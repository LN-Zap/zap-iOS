//
//  Zap
//
//  Created by Otto Suess on 25.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Lightning
import SwiftBTC
import SwiftLnd

class SendQRCodeScannerStrategy: QRCodeScannerStrategy {
    private let lightningService: LightningService
    private let authenticationViewModel: AuthenticationViewModel

    let title = L10n.Scene.Send.title
    let pasteButtonTitle = L10n.Scene.Send.PasteButton.title

    init(lightningService: LightningService, authenticationViewModel: AuthenticationViewModel) {
        self.lightningService = lightningService
        self.authenticationViewModel = authenticationViewModel
    }

    func viewControllerForAddress(address: String, completion: @escaping (Result<UIViewController, QRCodeScannerStrategyError>) -> Void) {
        BitcoinInvoiceFactory.create(from: address, lightningService: lightningService) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let invoice):
                let viewModel = SendViewModel(
                    invoice: invoice,
                    lightningService: self.lightningService
                )
                completion(.success(SendViewController(viewModel: viewModel, authenticationViewModel: self.authenticationViewModel)))
            case .failure(let error):
                switch error {
                case .unknownFormat:
                    completion(.failure(.init(message: L10n.Scene.QrcodeScanner.Error.unknownFormat)))
                case let .wrongNetworkError(linkNetwork, expectedNetwork):
                    completion(.failure(.init(message: L10n.Scene.QrcodeScanner.Error.wrongNetwork(linkNetwork.localized, expectedNetwork.localized))))
                case .apiError:
                    completion(.failure(.init(message: L10n.Scene.QrcodeScanner.Error.zeroAmountInvoice)))
                }
            }
        }
    }
}

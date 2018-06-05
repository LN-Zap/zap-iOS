//
//  Zap
//
//  Created by Otto Suess on 31.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static func instantiateDetailViewController(with viewModel: ViewModel, detailViewModel: DetailViewModel) -> UINavigationController {
        let viewController = Storyboard.detail.initial(viewController: UINavigationController.self)
        if let detailViewController = viewController.topViewController as? DetailViewController {
            detailViewController.detailViewModel = detailViewModel
            detailViewController.viewModel = viewModel
        }
        return viewController
    }
    
    static func instantiateSettingsContainerViewController(with viewModel: ViewModel) -> UINavigationController {
        let viewController = Storyboard.settings.initial(viewController: UINavigationController.self)
        
        if let settingsContainerViewController = viewController.topViewController as? SettingsContainerViewController {
            settingsContainerViewController.viewModel = viewModel
        }

        return viewController
    }
    
    static func instantiateDebugViewController() -> UINavigationController {
        return Storyboard.debug.initial(viewController: UINavigationController.self)
    }
    
    static func instantiateQRCodeScannerViewController(with viewModel: ViewModel, strategy: QRCodeScannerStrategy) -> UINavigationController {
        let navigationController = Storyboard.qrCodeScanner.initial(viewController: UINavigationController.self)
        if let viewController = navigationController.topViewController as? QRCodeScannerViewController {
            viewController.viewModel = viewModel
            viewController.strategy = strategy
        }
        return navigationController
    }
    
    static func instantiateRequestViewController(with viewModel: ViewModel) -> UINavigationController {
        let navigationController = Storyboard.request.initial(viewController: UINavigationController.self)
        if let viewController = navigationController.topViewController as? RequestViewController {
            viewController.viewModel = viewModel
        }
        return navigationController
    }
}

enum Storyboard: String {
    case channelList
    case connectRemoteNode
    case createWallet
    case debug
    case deposit
    case invoiceDetail
    case loading
    case main
    case numericKeyPad
    case openChannel
    case paymentDetail
    case qrCodeDetail = "QRCodeDetail"
    case qrCodeScanner = "QRCodeScanner"
    case request
    case send
    case sendOnChain
    case settings
    case sync
    case detail
    case transactionList
    
    var storyboard: UIStoryboard? {
        let storyboardName = uppercasedStart(rawValue)
        return UIStoryboard(name: storyboardName, bundle: nil)
    }
    
    func instantiate<VC: UIViewController>(viewController: VC.Type) -> VC {
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: storyboardIdentifier(VC.self)) as? VC
            else { fatalError("Couldn't instantiate \(storyboardIdentifier(VC.self)) from \(self.rawValue)") }
        return viewController
    }
    
    func initial<VC: UIViewController>(viewController: VC.Type) -> VC {
        guard let viewController = storyboard?.instantiateInitialViewController() as? VC
            else { fatalError("Couldn't instantiate \(storyboardIdentifier(VC.self)) from \(self.rawValue)") }
        return viewController
    }
    
    private func uppercasedStart(_ string: String) -> String {
        var text = string
        let first = text.remove(at: text.startIndex)
        return "\(first.description.uppercased())\(text)"
    }
    
    private func storyboardIdentifier<VC: UIViewController>(_ viewController: VC.Type) -> String {
        return viewController.description().components(separatedBy: ".").dropFirst().joined(separator: ".")
    }
}

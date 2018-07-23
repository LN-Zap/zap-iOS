//
//  Zap
//
//  Created by Otto Suess on 31.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

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
    case root
    case send
    case sendOnChain
    case settings
    case sync
    case detail
    case transactionList
    
    var storyboard: UIStoryboard? {
        let storyboardName = uppercasedStart(rawValue)
        return UIStoryboard(name: storyboardName, bundle: Bundle.library)
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

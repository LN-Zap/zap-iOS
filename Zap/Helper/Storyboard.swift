//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

enum Storyboard: String {
    case channelList
    case createWallet
    case deposit
    case loading
    case main
    case numericKeyPad
    case paymentDetail
    case qrCodeDetail = "QRCodeDetail"
    case qrCodeScanner = "QRCodeScanner"
    case receive
    case send
    case settings
    case sync
    case transactionDetail
    case transactionList
    case withdraw
    
    var storyboard: UIStoryboard? {
        let storyboardName = rawValue.uppercasedStart()
        return UIStoryboard(name: storyboardName, bundle: nil)
    }
    
    public func instantiate<VC: UIViewController>(viewController: VC.Type) -> VC {
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: VC.storyboardIdentifier) as? VC
            else { fatalError("Couldn't instantiate \(VC.storyboardIdentifier) from \(self.rawValue)") }
        return viewController
    }
    
    public func initial<VC: UIViewController>(viewController: VC.Type) -> VC {
        guard let viewController = storyboard?.instantiateInitialViewController() as? VC
            else { fatalError("Couldn't instantiate \(VC.storyboardIdentifier) from \(self.rawValue)") }
        return viewController
    }
    
    public func initial() -> UIViewController {
        guard let viewController = storyboard?.instantiateInitialViewController()
            else { fatalError("Couldn't instantiate initial ViewController from \(self.rawValue)") }
        return viewController
    }
}

fileprivate extension UIViewController {
    static var storyboardIdentifier: String {
        return self.description().components(separatedBy: ".").dropFirst().joined(separator: ".")
    }
}

fileprivate extension String {
    func uppercasedStart() -> String {
        var text = self
        let first = text.remove(at: text.startIndex)
        return "\(first.description.uppercased())\(text)"
    }
}

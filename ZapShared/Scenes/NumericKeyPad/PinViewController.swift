//
//  Zap
//
//  Created by Otto Suess on 27.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static func instantiatePinViewController(didAuthenticate: @escaping () -> Void) -> PinViewController {
        let pinViewController = Storyboard.numericKeyPad.initial(viewController: PinViewController.self)
        pinViewController.didAuthenticate = didAuthenticate
        return pinViewController
    }
}

final class PinViewController: UIViewController {
    @IBOutlet private weak var pinStackView: PinView!
    @IBOutlet private weak var keyPadView: KeyPadView!
    
    fileprivate var didAuthenticate: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let authenticationService = AuthenticationService.shared
        pinStackView.characterCount = authenticationService.pinLength ?? 0
        
        setupKeyPad()
    }
    
    private func setupKeyPad() {
        keyPadView.backgroundColor = UIColor.zap.charcoalGrey
        keyPadView.textColor = .white
        keyPadView.state = .authenticate
        
        keyPadView.customPointButtonAction = { [weak self] in
            BiometricAuthentication.authenticate {
                guard $0.error == nil else { return }
                self?.didAuthenticate?()
            }
        }
        
        keyPadView.handler = { [weak self] number in
            self?.updatePinView(for: number)
            
            if AuthenticationService.shared.isMatchingPin(number) {
                self?.didAuthenticate?()
            }
            
            return (AuthenticationService.shared.pinLength ?? Int.max) >= number.count
        }
    }
    
    private func updatePinView(for string: String) {
        pinStackView.activeCount = string.count
    }
}

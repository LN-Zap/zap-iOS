//
//  Zap
//
//  Created by Otto Suess on 27.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Lightning
import UIKit

extension UIStoryboard {
    static func instantiatePinViewController(authenticationViewModel: AuthenticationViewModel, didAuthenticate: @escaping () -> Void) -> PinViewController {
        let pinViewController = Storyboard.numericKeyPad.initial(viewController: PinViewController.self)
        pinViewController.authenticationViewModel = authenticationViewModel
        pinViewController.didAuthenticate = didAuthenticate
        return pinViewController
    }
}

final class PinViewController: UIViewController {
    @IBOutlet private weak var pinStackView: PinView!
    @IBOutlet private weak var keyPadView: KeyPadView!
    
    fileprivate var authenticationViewModel: AuthenticationViewModel?
    fileprivate var didAuthenticate: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pinStackView.characterCount = authenticationViewModel?.pinLength ?? 0
        
        setupKeyPad()
    }
    
    private func setupKeyPad() {
        guard let authenticationViewModel = authenticationViewModel else { return }
        keyPadView.backgroundColor = UIColor.zap.charcoalGrey
        keyPadView.textColor = .white
        keyPadView.state = .authenticate
        
        keyPadView.customPointButtonAction = { [weak self] in
            BiometricAuthentication.authenticate {
                guard $0.error == nil else { return }
                self?.authenticationViewModel?.didAuthenticate()
                self?.didAuthenticate?()
            }
        }
        
        keyPadView.handler = { [weak self] number in
            self?.updatePinView(for: number)
            
            if authenticationViewModel.isMatchingPin(number) {
                self?.authenticationViewModel?.didAuthenticate()
                self?.didAuthenticate?()
            }
            
            return (authenticationViewModel.pinLength ?? Int.max) >= number.count
        }
    }
    
    private func updatePinView(for string: String) {
        pinStackView.activeCount = string.count
    }
}

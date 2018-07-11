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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startBiometricAuthentication()
    }
    
    private func setupKeyPad() {
        guard let authenticationViewModel = authenticationViewModel else { return }
        keyPadView.backgroundColor = UIColor.zap.charcoalGrey
        keyPadView.textColor = .white
        keyPadView.state = .authenticate
        
        keyPadView.customPointButtonAction = { [weak self] in
            self?.startBiometricAuthentication()
        }
        
        keyPadView.handler = { [weak self] number in
            self?.updatePinView(for: number)
            self?.checkPin(string: number)
            
            return (authenticationViewModel.pinLength ?? Int.max) > number.count
        }
    }
    
    private func startBiometricAuthentication() {
        BiometricAuthentication.authenticate { [weak self] in
            guard $0.error == nil else { return }
            self?.authenticationViewModel?.didAuthenticate()
            self?.didAuthenticate?()
        }
    }
    
    private func updatePinView(for string: String) {
        pinStackView.activeCount = string.count
    }
    
    private func checkPin(string: String) {
        guard let authenticationViewModel = authenticationViewModel else { return }

        if authenticationViewModel.isMatchingPin(string) {
            authenticationViewModel.didAuthenticate()
            didAuthenticate?()
        } else if authenticationViewModel.pinLength == string.count {
            keyPadView.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.keyPadView.isUserInteractionEnabled = true
                self?.keyPadView.numberString = ""
                self?.updatePinView(for: "")
            }
        }
    }
}

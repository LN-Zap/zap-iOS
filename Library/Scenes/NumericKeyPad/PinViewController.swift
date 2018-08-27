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
        pinViewController.didAuthenticateCallback = didAuthenticate
        return pinViewController
    }
}

final class PinViewController: UIViewController {
    @IBOutlet private weak var pinView: PinView!
    @IBOutlet private weak var keyPadView: KeyPadPinView!
    
    fileprivate var authenticationViewModel: AuthenticationViewModel?
    fileprivate var didAuthenticateCallback: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.Zap.seaBlue
        
        setupKeyPad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startBiometricAuthentication()
    }
    
    private func setupKeyPad() {
        guard let authenticationViewModel = authenticationViewModel else { return }
        keyPadView.backgroundColor = UIColor.Zap.seaBlue
        keyPadView.textColor = .white
        keyPadView.authenticationViewModel = authenticationViewModel
        keyPadView.delegate = self
        keyPadView.pinView = pinView
    }
}

extension PinViewController: KeyPadPinViewDelegate {
    func startBiometricAuthentication() {
        guard BiometricAuthentication.type != .none else { return }
        
        BiometricAuthentication.authenticate { [weak self] in
            guard $0.error == nil else { return }
            self?.authenticationViewModel?.didAuthenticate()
            self?.didAuthenticate()
        }
    }
    
    func didAuthenticate() {
        didAuthenticateCallback?()
    }
}

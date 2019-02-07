//
//  Zap
//
//  Created by Otto Suess on 27.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Lightning
import UIKit

final class PinViewController: UIViewController {
    @IBOutlet private weak var pinView: PinView!
    @IBOutlet private weak var keyPadView: KeyPadPinView!
    @IBOutlet private weak var imageBottomConstraint: NSLayoutConstraint!
    
    fileprivate var authenticationViewModel: AuthenticationViewModel?
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    static func instantiate(authenticationViewModel: AuthenticationViewModel) -> PinViewController {
        let pinViewController = StoryboardScene.NumericKeyPad.initialScene.instantiate()
        pinViewController.authenticationViewModel = authenticationViewModel
        return pinViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.Zap.background
        
        setupKeyPad()
        
        let shouldPinInputBeHidden = BiometricAuthentication.type != .none
        setPinView(hidden: shouldPinInputBeHidden, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if BiometricAuthentication.type != .none {
            startBiometricAuthentication()
        }
    }
    
    private func setupKeyPad() {
        keyPadView.authenticationViewModel = authenticationViewModel
        keyPadView.delegate = self
        keyPadView.pinView = pinView
    }
    
    func setPinView(hidden: Bool, animated: Bool) {
        let block = {
            let alpha: CGFloat = hidden ? 0 : 1
            self.pinView.alpha = alpha
            self.keyPadView.alpha = alpha
            self.imageBottomConstraint.priority = UILayoutPriority(rawValue: hidden ? 749 : 751)
        }
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                block()
                self.view.layoutIfNeeded()
            }
        } else {
            block()
        }
    }
}

extension PinViewController: KeyPadPinViewDelegate {
    func startBiometricAuthentication() {
        guard BiometricAuthentication.type != .none else { return }
        
        BiometricAuthentication.authenticate { [weak self] result in
            switch result {
            case .success:
                self?.authenticationViewModel?.didAuthenticate()
            case .failure:
                self?.setPinView(hidden: false, animated: true)
            }
        }
    }
    
    func didAuthenticate() {}
}

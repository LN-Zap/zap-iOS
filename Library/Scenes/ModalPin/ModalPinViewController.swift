//
//  Library
//
//  Created by Otto Suess on 27.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
import UIKit

extension UIStoryboard {
    static func instantiateModalPinViewController(authenticationViewModel: AuthenticationViewModel) -> ModalPinViewController {
        let viewController = Storyboard.modalPin.instantiate(viewController: ModalPinViewController.self)
        viewController.authenticationViewModel = authenticationViewModel
        return viewController
    }
}

final class ModalPinViewController: ModalViewController, ContentHeightProviding {
    var authenticationViewModel: AuthenticationViewModel?

    var window: UIWindow?
    
    @IBOutlet private weak var keyPadPinView: KeyPadPinView!
    @IBOutlet private weak var keyPadContainer: UIView!
    @IBOutlet private weak var pinView: PinView!
    @IBOutlet private weak var pinViewContainer: UIView!
    @IBOutlet private weak var cancelButton: UIButton!
    
    var contentHeight: CGFloat? { return window?.bounds.height }
    var completion: ((Result<Success>) -> Void)?
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pinView.activeColor = .black
        pinView.inactiveColor = UIColor.Zap.gray
        
        keyPadContainer.layer.cornerRadius = Appearance.Constants.modalCornerRadius
        keyPadContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

        pinViewContainer.layer.cornerRadius = Appearance.Constants.modalCornerRadius
        
        keyPadPinView.state = .pin
        keyPadPinView.delegate = self
        keyPadPinView.authenticationViewModel = authenticationViewModel
        keyPadPinView.pinView = pinView
        
        Style.Button.custom().apply(to: cancelButton)
        cancelButton.setTitle("generic.cancel".localized, for: .normal)
    }
    
    static func authenticate(authenticationViewModel: AuthenticationViewModel, completion: @escaping (Result<Success>) -> Void) {
        let pinWindow = UIWindow(frame: UIScreen.main.bounds)
        pinWindow.rootViewController = RootViewController()
        pinWindow.windowLevel = UIWindowLevelAlert + 1
        pinWindow.makeKeyAndVisible()
        
        let modalPinViewController = UIStoryboard.instantiateModalPinViewController(authenticationViewModel: authenticationViewModel)
        modalPinViewController.window = pinWindow
        modalPinViewController.completion = completion
        
        pinWindow.rootViewController?.present(modalPinViewController, animated: true, completion: nil)
    }
    
    @IBAction private func cancel(_ sender: Any) {
        dismiss(animated: true) { [weak self] in
            self?.completion?(.failure(AuthenticationError.canceled))
        }
    }
}

extension ModalPinViewController: KeyPadPinViewDelegate {
    func startBiometricAuthentication() {
        fatalError("should be disabled")
    }
    
    func didAuthenticate() {
        self.dismiss(animated: true) { [weak self] in
            self?.completion?(.success(Success()))
        }
    }
}

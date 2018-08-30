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
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    var completion: ((Result<Success>) -> Void)?
    var contentHeight: CGFloat? { return window?.bounds.height } // ContentHeightProviding
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyPadContainer.layer.cornerRadius = Appearance.Constants.modalCornerRadius
        keyPadContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        keyPadContainer.backgroundColor = UIColor.Zap.seaBlue
        
        pinViewContainer.layer.cornerRadius = Appearance.Constants.modalCornerRadius
        pinViewContainer.backgroundColor = UIColor.Zap.seaBlue
        
        keyPadPinView.state = .pin
        keyPadPinView.delegate = self
        keyPadPinView.authenticationViewModel = authenticationViewModel
        keyPadPinView.pinView = pinView
        
        Style.Label.headline.apply(to: headlineLabel)
        headlineLabel.text = "scene.modal_pin.headline".localized
        Style.Label.body.apply(to: descriptionLabel)
        descriptionLabel.text = "scene.modal_pin.description".localized
        
        Style.Button.custom().apply(to: cancelButton)
        cancelButton.setTitle("generic.cancel".localized, for: .normal)
    }
    
    static func authenticate(authenticationViewModel: AuthenticationViewModel, completion: @escaping (Result<Success>) -> Void) {
        let pinWindow = UIWindow(frame: UIScreen.main.bounds)
        pinWindow.rootViewController = RootViewController()
        pinWindow.windowLevel = WindowLevel.modalPin
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

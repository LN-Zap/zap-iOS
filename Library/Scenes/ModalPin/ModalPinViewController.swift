//
//  Library
//
//  Created by Otto Suess on 27.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
import SwiftLnd
import UIKit

final class ModalPinViewController: ModalViewController, ContentHeightProviding {
    @IBOutlet private weak var keyPadPinView: KeyPadPinView!
    @IBOutlet private weak var keyPadContainer: UIView!
    @IBOutlet private weak var pinView: PinView!
    @IBOutlet private weak var pinViewContainer: UIView!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    fileprivate var authenticationViewModel: AuthenticationViewModel?
    fileprivate var window: UIWindow?
    fileprivate var completion: ((Result<Success>) -> Void)?
    
    var contentHeight: CGFloat? { return window?.bounds.height } // ContentHeightProviding
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    private static func instantiate(authenticationViewModel: AuthenticationViewModel, window: UIWindow, completion: @escaping ((Result<Success>) -> Void)) -> ModalPinViewController {
        let viewController = StoryboardScene.ModalPin.modalPinViewController.instantiate()
        viewController.authenticationViewModel = authenticationViewModel
        viewController.window = window
        viewController.completion = completion
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyPadContainer.layer.cornerRadius = Appearance.Constants.modalCornerRadius
        keyPadContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        keyPadContainer.backgroundColor = UIColor.Zap.background
        
        pinViewContainer.layer.cornerRadius = Appearance.Constants.modalCornerRadius
        pinViewContainer.backgroundColor = UIColor.Zap.background
        
        keyPadPinView.state = .pin
        keyPadPinView.delegate = self
        keyPadPinView.authenticationViewModel = authenticationViewModel
        keyPadPinView.pinView = pinView
        
        Style.Label.headline.apply(to: headlineLabel)
        headlineLabel.text = L10n.Scene.ModalPin.headline
        Style.Label.body.apply(to: descriptionLabel)
        descriptionLabel.text = L10n.Scene.ModalPin.description
        
        Style.Button.custom().apply(to: cancelButton)
        cancelButton.setTitle(L10n.Generic.cancel, for: .normal)
    }
    
    static func authenticate(authenticationViewModel: AuthenticationViewModel, completion: @escaping (Result<Success>) -> Void) {
        let pinWindow = UIWindow(frame: UIScreen.main.bounds)
        pinWindow.rootViewController = RootViewController()
        pinWindow.windowLevel = WindowLevel.modalPin
        pinWindow.makeKeyAndVisible()
        
        let modalPinViewController = ModalPinViewController.instantiate(authenticationViewModel: authenticationViewModel, window: pinWindow, completion: completion)
        
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

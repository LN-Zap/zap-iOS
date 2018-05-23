//
//  Zap
//
//  Created by Otto Suess on 27.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

protocol PinViewDelegate: class {
    func didAuthenticate()
}

class PinViewController: UIViewController {
    
    @IBOutlet private weak var pinStackView: PinView!
    @IBOutlet private weak var keyPadView: KeyPadView!
    
    weak var delegate: PinViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewModel = AuthenticationViewModel.shared
        
        pinStackView.characterCount = viewModel.pin?.count ?? 0
        
        view.backgroundColor = UIColor.zap.darkBackground
        
        setupKeyPad()
    }
    
    private func setupKeyPad() {
        keyPadView.backgroundColor = UIColor.zap.darkBackground
        keyPadView.textColor = .white
        keyPadView.state = .authenticate
        
        keyPadView.customPointButtonAction = { [weak self] in
            BiometricAuthentication.authenticate {
                guard $0.error == nil else { return }
                self?.delegate?.didAuthenticate()
            }
        }
        
        keyPadView.handler = { [weak self] number in
            self?.updatePinView(for: number)
            
            if AuthenticationViewModel.shared.pin == number {
                self?.delegate?.didAuthenticate()
            }
            
            return (AuthenticationViewModel.shared.pin?.count ?? Int.max) >= number.count
        }
    }
    
    private func updatePinView(for string: String) {
        pinStackView.activeCount = string.count
    }
}

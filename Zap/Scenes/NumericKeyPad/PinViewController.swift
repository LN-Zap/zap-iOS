//
//  Zap
//
//  Created by Otto Suess on 27.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

class PinViewController: UIViewController {
    
    @IBOutlet private weak var pinStackView: PinView!
    
    var viewModel: ViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewModel = AuthenticationViewModel.instance
        
        pinStackView.characterCount = viewModel.pin?.count ?? 0
        
        view.backgroundColor = Color.darkBackground        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let numPad = segue.destination as? NumericKeyPadViewController {
            setupNumPad(viewController: numPad)
        }
    }
    
    private func setupNumPad(viewController: NumericKeyPadViewController) {
        viewController.view.backgroundColor = .clear
        viewController.textColor = .white
        viewController.state = .authenticate
        
        viewController.customPointButtonAction = { [weak self] in
            BiometricAuthentication.authenticate {
                guard $0.error == nil else { return }
                self?.setAuthenticated()
            }
        }
        
        viewController.handler = { [weak self] number in
            self?.updatePinView(for: number)
            
            if AuthenticationViewModel.instance.pin == number {
                self?.setAuthenticated()
            }
            
            return (AuthenticationViewModel.instance.pin?.count ?? Int.max) >= number.count
        }
    }
    
    private func updatePinView(for string: String) {
        pinStackView.activeCount = string.count
    }
    
    private func setAuthenticated() {
        viewModel?.isLocked = false
    }
}

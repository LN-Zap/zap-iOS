//
//  Zap
//
//  Created by Otto Suess on 23.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import ReactiveKit
import UIKit

extension UIStoryboard {
    static func instantiateSetupPinViewController(setupPinViewModel: SetupPinViewModel, didSetupPin: @escaping () -> Void) -> SetupPinViewController {
        let setupPinViewController = Storyboard.numericKeyPad.instantiate(viewController: SetupPinViewController.self)
        setupPinViewController.setupPinViewModel = setupPinViewModel
        setupPinViewController.didSetupPin = didSetupPin
        return setupPinViewController
    }
}

final class SetupPinViewController: UIViewController {

    @IBOutlet private weak var doneButton: UIButton!
    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var pinStackView: PinView!
    @IBOutlet private weak var keyPadView: KeyPadView!
    
    fileprivate var setupPinViewModel: SetupPinViewModel?
    fileprivate var didSetupPin: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let setupPinViewModel = setupPinViewModel else { return }
        
        view.backgroundColor = UIColor.zap.seaBlue
        
        Style.label(color: .white).apply(to: topLabel)
        Style.button(color: .white).apply(to: doneButton)
        
        setupKeyPad()
        
        [setupPinViewModel.state
            .observeNext { [weak self] in
                guard let state = $0 else { return }
                switch state {
                case .reset:
                    self?.keyPadView?.numberString = ""
                case .completed:
                    print("completed")
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    self?.didSetupPin?()
                }
            },
         combineLatest(setupPinViewModel.pinCharacterCount, setupPinViewModel.pinAtiveCount)
            .observeNext { [weak self] in
                self?.updatePinView(characterCount: $0, activeCount: $1)
            },
         setupPinViewModel.doneButtonEnabled.bind(to: doneButton.reactive.isEnabled),
         setupPinViewModel.topLabelText.bind(to: topLabel.reactive.text)]
            .dispose(in: reactive.bag)
        
        doneButton.setTitle("scene.setup_pin.done_button".localized, for: .normal)
    }
    
    private func setupKeyPad() {
        guard let setupPinViewModel = setupPinViewModel else { return }
        
        keyPadView.backgroundColor = UIColor.zap.seaBlue
        keyPadView.textColor = .white
        keyPadView.state = .setupPin
        
        keyPadView.handler = { [setupPinViewModel] in
            return setupPinViewModel.updateCurrentPin($0)
        }
    }
    
    @IBAction private func doneButtonTapped(_ sender: Any) {
        setupPinViewModel?.doneButtonTapped()
        keyPadView.numberString = ""
    }
    
    private func updatePinView(characterCount: Int, activeCount: Int) {
        pinStackView?.characterCount = characterCount
        pinStackView?.activeCount = activeCount
    }
}

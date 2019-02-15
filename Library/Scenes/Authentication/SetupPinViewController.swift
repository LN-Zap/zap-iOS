//
//  Zap
//
//  Created by Otto Suess on 23.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import ReactiveKit
import UIKit

final class SetupPinViewController: UIViewController {

    @IBOutlet private weak var doneButton: UIButton!
    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var pinStackView: PinView!
    @IBOutlet private weak var keyPadView: KeyPadView!
    
    private var setupPinViewModel: SetupPinViewModel?
    private var didSetupPin: (() -> Void)?
    
    static func instantiate(setupPinViewModel: SetupPinViewModel, didSetupPin: @escaping () -> Void) -> SetupPinViewController {
        let setupPinViewController = StoryboardScene.NumericKeyPad.setupPinViewController.instantiate()
        setupPinViewController.setupPinViewModel = setupPinViewModel
        setupPinViewController.didSetupPin = didSetupPin
        return setupPinViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let setupPinViewModel = setupPinViewModel else { return }
        
        view.backgroundColor = UIColor.Zap.background
        
        Style.Label.body.apply(to: topLabel)
        Style.Button.background.apply(to: doneButton)
        
        setupKeyPad()
        
        [setupPinViewModel.state
            .observeNext { [weak self] in
                guard let state = $0 else { return }
                switch state {
                case .reset:
                    self?.keyPadView?.numberString = ""
                case .completed:
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
        
        doneButton.setTitle(L10n.Scene.SetupPin.doneButton, for: .normal)
    }
    
    private func setupKeyPad() {
        guard let setupPinViewModel = setupPinViewModel else { return }
        
        keyPadView.backgroundColor = UIColor.Zap.background
        keyPadView.textColor = .white
        keyPadView.state = .pin
        
        keyPadView.handler = { [setupPinViewModel] in
            setupPinViewModel.updateCurrentPin($0)
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

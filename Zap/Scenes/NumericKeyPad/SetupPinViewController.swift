//
//  Zap
//
//  Created by Otto Suess on 23.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import ReactiveKit
import UIKit

class SetupPinViewController: UIViewController {

    @IBOutlet private weak var doneButton: UIButton!
    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var pinStackView: PinView!
    @IBOutlet private weak var pinStackViewWidthConstraint: NSLayoutConstraint!
    
    private weak var numericKeyPadViewController: NumericKeyPadViewController?
    private let setupPinViewModel = SetupPinViewModel()
    
    var viewModel: ViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Style.label.apply(to: topLabel) {
            $0.textColor = .white
        }
        Style.button.apply(to: doneButton) {
            $0.tintColor = .white
        }
        
        setupPinViewModel.state
            .observeNext { [weak self] in
                guard let state = $0 else { return }
                switch state {
                case .reset:
                    self?.numericKeyPadViewController?.numberString = ""
                case .completed:
                    self?.dismiss(animated: true, completion: nil)
                    self?.viewModel?.walletState.value = .connecting
                }
            }
            .dispose(in: reactive.bag)
        combineLatest(setupPinViewModel.pinCharacterCount, setupPinViewModel.pinAtiveCount)
            .observeNext { [weak self] in
                self?.updatePinView(characterCount: $0, activeCount: $1)
            }
            .dispose(in: reactive.bag)
        setupPinViewModel.doneButtonEnabled
            .bind(to: doneButton.reactive.isEnabled)
            .dispose(in: reactive.bag)
        setupPinViewModel.topLabelText
            .bind(to: topLabel.reactive.text)
            .dispose(in: reactive.bag)
        
        doneButton.setTitle("Done", for: .normal)
        view.backgroundColor = Color.darkBackground
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let numPad = segue.destination as? NumericKeyPadViewController {
            setupNumPad(viewController: numPad)
            numericKeyPadViewController = numPad
        }
    }
    
    private func setupNumPad(viewController: NumericKeyPadViewController) {
        viewController.view.backgroundColor = .clear
        viewController.textColor = .white
        viewController.state = .setupPin
        
        viewController.handler = { [setupPinViewModel] in
            return setupPinViewModel.updateCurrentPin($0)
        }
    }
    
    @IBAction private func doneButtonTapped(_ sender: Any) {
        setupPinViewModel.doneButtonTapped()
        numericKeyPadViewController?.numberString = ""
    }
    
    private func updatePinView(characterCount: Int, activeCount: Int) {
        pinStackView.characterCount = characterCount
        pinStackView.activeCount = activeCount
        view?.layoutIfNeeded()
        
        if characterCount <= 1 {
            pinStackViewWidthConstraint.constant = pinStackView.bounds.height
        } else {
            pinStackViewWidthConstraint.constant = pinStackView.bounds.height * CGFloat(characterCount) + (CGFloat(characterCount) - 1) * 20
        }
        
        UIView.animate(withDuration: 0.2) { [view] in
            view?.layoutIfNeeded()
        }
    }
}

//
//  Zap
//
//  Created by Otto Suess on 09.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import UIKit

class ConfirmMnemonicViewController: UIViewController {

    @IBOutlet private weak var mnemonicWordLabel: UILabel!
    @IBOutlet private weak var mnemonicWordTextField: UITextField!
    @IBOutlet private weak var doneButton: UIButton!
    
    var confirmViewModel: ConfirmMnemonicViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.darkBackground

        Style.label.apply(to: mnemonicWordLabel) {
            $0.textColor = .white
        }
        Style.button.apply(to: doneButton)
        
        mnemonicWordTextField.backgroundColor = .white
        
        doneButton.setTitle("ok", for: .normal)
        
        mnemonicWordTextField.becomeFirstResponder()
        
        confirmViewModel?.wordLabel
            .bind(to: mnemonicWordLabel.reactive.text)
            .dispose(in: reactive.bag)
        
        confirmViewModel?.checkCompleted
            .filter { $0 }
            .observeNext { _ in print("DONE") }
            .dispose(in: reactive.bag)
    }
    
    @IBAction private func doneButtonTapped(_ sender: Any) {
        checkInput()
    }
    
    private func checkInput() {
        guard
            let confirmViewModel = confirmViewModel,
            let text = mnemonicWordTextField.text
            else { return }
        
        if confirmViewModel.check(mnemonic: text) {
            mnemonicWordTextField.text = nil
        }
    }
}

extension ConfirmMnemonicViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        checkInput()
        return false
    }
}

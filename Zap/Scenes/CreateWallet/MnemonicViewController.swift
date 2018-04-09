//
//  Zap
//
//  Created by Otto Suess on 19.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Foundation

final class MnemonicViewController: UIViewController {
    @IBOutlet private weak var mnemoniceLabel: UILabel!
    @IBOutlet private weak var doneButton: UIButton!

    var mnemonicViewModel: MnemonicViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Color.darkBackground
        
        Style.label.apply(to: mnemoniceLabel) {
            $0.textColor = .white
        }
        Style.button.apply(to: doneButton)
        
        doneButton.setTitle("done", for: .normal)
        
        mnemonicViewModel?.wordList
            .map { $0.enumerated().map({ "\($0 + 1)\t\($1)" }).joined(separator: "\n") }
            .bind(to: mnemoniceLabel.reactive.text)
            .dispose(in: reactive.bag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ConfirmMnemonicViewController {
            destination.confirmViewModel = mnemonicViewModel?.confirmMnemonicViewModel
        }
    }
}

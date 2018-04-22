//
//  Zap
//
//  Created by Otto Suess on 19.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Foundation

final class MnemonicViewController: UIViewController {
    @IBOutlet private weak var doneButton: UIButton!
    @IBOutlet private weak var topLabel: UILabel!
    
    private weak var pageViewController: MnemonicPageViewController?
    var mnemonicViewModel: MnemonicViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Color.darkBackground
        
        Style.button.apply(to: doneButton)
        Style.label.apply(to: topLabel)
        topLabel.textColor = .white
        topLabel.text = "Save your mnemonic text. Bitcoin Bitcoin Bitcoin Bitcoin Bitcoin Bitcoin."
        
        doneButton.setTitle("Next", for: .normal)
        doneButton.tintColor = .white
    }
    
    @IBAction private func nextButtonTapped(_ sender: Any) {
        if pageViewController?.isLastViewController == true {
            performSegue(withIdentifier: "presentConfirmMnemonic", sender: nil)
        } else {
            pageViewController?.skipToNextViewController()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ConfirmMnemonicViewController {
            destination.confirmViewModel = mnemonicViewModel?.confirmMnemonicViewModel
        } else if let destination = segue.destination as? MnemonicPageViewController {
            destination.mnemonicViewModel = mnemonicViewModel
            pageViewController = destination
        }
    }
}

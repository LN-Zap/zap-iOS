//
//  Zap
//
//  Created by Otto Suess on 09.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class SelectWalletCreationMethodViewController: UIViewController {

    @IBOutlet weak private var createMainLabel: UILabel!
    @IBOutlet weak private var createDescriptionLabel: UILabel!
    @IBOutlet weak private var recoverMainLabel: UILabel!
    @IBOutlet weak private var recoverDescriptionLabel: UILabel!
    
    var viewModel: ViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Color.darkBackground

        Style.label.apply(to: createMainLabel, recoverMainLabel) {
            $0.textColor = .white
            $0.font = $0.font.withSize(36)
        }
        Style.label.apply(to: createDescriptionLabel, recoverDescriptionLabel) {
            $0.textColor = .white
            $0.font = $0.font.withSize(18)
        }
        
        createMainLabel.text = "Create"
        createDescriptionLabel.text = "new wallet"
        recoverMainLabel.text = "Recover"
        recoverDescriptionLabel.text =  "Existing wallet"
        
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let viewModel = viewModel,
            let destination = segue.destination as? MnemonicViewController
            else { return }
        destination.mnemonicViewModel = MnemonicViewModel(viewModel: viewModel)
    }
}

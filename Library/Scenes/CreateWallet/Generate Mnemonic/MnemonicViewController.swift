//
//  Zap
//
//  Created by Otto Suess on 19.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Foundation

extension UIStoryboard {
    static func instantiateMnemonicViewController(mnemonicViewModel: MnemonicViewModel, presentConfirmMnemonic: @escaping () -> Void) -> MnemonicViewController {
        let viewController = Storyboard.createWallet.instantiate(viewController: MnemonicViewController.self)
        viewController.mnemonicViewModel = mnemonicViewModel
        viewController.presentConfirmMnemonic = presentConfirmMnemonic
        return viewController
    }
}

final class MnemonicViewController: UIViewController {
    @IBOutlet private weak var doneButton: UIButton!
    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private weak var pageViewController: MnemonicPageViewController?
    
    fileprivate var mnemonicViewModel: MnemonicViewModel?
    fileprivate var presentConfirmMnemonic: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "scene.create_wallet.title".localized
        
        Style.button().apply(to: doneButton)
        Style.label().apply(to: topLabel)
        topLabel.textColor = .white
        topLabel.text = "scene.create_wallet.description_label".localized
        
        doneButton.setTitle("scene.create_wallet.next_button".localized, for: .normal)
        doneButton.tintColor = .white
        
        mnemonicViewModel?.pageWords
            .map { $0 != nil }
            .observeOn(DispatchQueue.main)
            .bind(to: activityIndicator.reactive.isHidden)
            .dispose(in: reactive.bag)
    }
    
    @IBAction private func nextButtonTapped(_ sender: Any) {
        if pageViewController?.isLastViewController == true {
            presentConfirmMnemonic?()
        } else {
            pageViewController?.skipToNextViewController()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MnemonicPageViewController {
            destination.mnemonicViewModel = mnemonicViewModel
            pageViewController = destination
        }
    }
}

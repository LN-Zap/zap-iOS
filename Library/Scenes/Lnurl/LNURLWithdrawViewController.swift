//
//  Library
//
//  Created by 0 on 08.11.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import SwiftBTC

final class LNURLWithdrawViewController: UIViewController {
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var withdrawButton: UIButton!
    @IBOutlet private weak var slider: UISlider!
    
    // swiftlint:disable implicitly_unwrapped_optional
    private var viewModel: LNURLWithdrawViewModel!
    // swiftlint:enable implicitly_unwrapped_optional
    
    static func instantiate(viewModel: LNURLWithdrawViewModel) -> LNURLWithdrawViewController {
        let viewController = StoryboardScene.LNURLWithdraw.lnurlWithdrawViewController.instantiate()
        viewController.viewModel = viewModel
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.Scene.Lnurl.Withdraw.title
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationController?.navigationBar.prefersLargeTitles = false
        
        view.backgroundColor = UIColor.Zap.background
        
        withdrawButton.setTitle(L10n.Scene.Lnurl.Withdraw.buttonTitle, for: .normal)
        Style.Button.background.apply(to: withdrawButton)
        
        viewModel.selectedAmount
            .bind(to: amountLabel.reactive.text, currency: Settings.shared.primaryCurrency)
            .dispose(in: reactive.bag)
        
        amountLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 80, weight: .regular)
        amountLabel.textColor = .white
        amountLabel.adjustsFontSizeToFitWidth = true
        
        let descriptionString = NSMutableAttributedString(string: L10n.Scene.Lnurl.Withdraw.description + ": ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.Zap.gray])
        descriptionString.append(NSAttributedString(string: viewModel.description.quoted))
        descriptionLabel.attributedText = descriptionString
        
        if viewModel.minWithdrawable == viewModel.maxWithdrawable {
            slider.isHidden = true
        } else {
            slider.maximumValue = Float(truncating: viewModel.maxWithdrawable as NSNumber)
            slider.minimumValue = Float(truncating: viewModel.minWithdrawable as NSNumber)
            slider.value = slider.maximumValue
        }
    }
    
    @objc private func cancel() {
        dismiss(animated: true)
    }
    
    @IBAction private func amountChanged(_ sender: UISlider) {
        viewModel.selectedAmount.value = Satoshi(floatLiteral: Double(sender.value)).floored
    }
    
    @IBAction private func withdraw(_ sender: Any) {
        withdrawButton.isEnabled = false
        
        viewModel.withdraw { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.withdrawButton.isEnabled = true
                    Toast.presentError(error.localizedDescription)
                } else {
                    self?.dismiss(animated: true)
                }
            }
        }
    }
}

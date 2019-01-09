//
//  Library
//
//  Created by Otto Suess on 17.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

extension UIStoryboard {
    static func instantiateTipViewController(waiterRequestViewModel: WaiterRequestViewModel) -> TipViewController {
        let tipViewController = StoryboardScene.WalletInvoiceOnly.tipViewController.instantiate()
        tipViewController.waiterRequestViewModel = waiterRequestViewModel
        return tipViewController
    }
}

final class TipViewController: UIViewController {
    fileprivate var waiterRequestViewModel: WaiterRequestViewModel! // swiftlint:disable:this implicitly_unwrapped_optional
    
    @IBOutlet private weak var confirmButton: UIButton!
    @IBOutlet private weak var amountTitleLabel: UILabel!
    @IBOutlet private weak var primaryAmountLabel: UILabel!
    @IBOutlet private weak var tipDetailLabel: UILabel!
    @IBOutlet private weak var secondaryAmountLabel: UILabel!
    @IBOutlet private weak var tipTitleLabel: UILabel!
    @IBOutlet private weak var memoTitleLabel: UILabel!
    @IBOutlet private weak var memoLabel: UILabel!
    @IBOutlet private weak var tip1Button: UIButton!
    @IBOutlet private weak var tip2Button: UIButton!
    @IBOutlet private weak var tip3Button: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let waiterRequestViewModel = waiterRequestViewModel else { fatalError("waiterRequestViewModel not set") }
        
        view.backgroundColor = UIColor.Zap.background
        title = "Select Tip"
        navigationItem.largeTitleDisplayMode = .never
        
        Style.Label.headline.apply(to: amountTitleLabel, primaryAmountLabel, tipTitleLabel, memoTitleLabel)
        Style.Label.subHeadline.apply(to: tipDetailLabel, secondaryAmountLabel)
        Style.Label.body.apply(to: memoLabel)
        
        Style.Button.background.apply(to: [confirmButton, tip1Button, tip2Button, tip3Button])
        confirmButton.setTitle("Pay", for: .normal)
        
        setPercentTitle(to: tip1Button, value: waiterRequestViewModel.tipPercentages[0])
        setPercentTitle(to: tip2Button, value: waiterRequestViewModel.tipPercentages[1])
        setPercentTitle(to: tip3Button, value: waiterRequestViewModel.tipPercentages[2])
        
        amountTitleLabel.text = "Total"
        tipTitleLabel.text = "Add Tip"
        memoTitleLabel.text = "Memo"
        tipDetailLabel.isHidden = true
        
        waiterRequestViewModel.memo
            .bind(to: memoLabel.reactive.text)
            .dispose(in: reactive.bag)
        
        waiterRequestViewModel.totalAmount
            .map {
                let string = Settings.shared.primaryCurrency.value.format(satoshis: $0) ?? "0"
                let primaryString = NSMutableAttributedString(string: string, attributes: [.font: UIFont.monospacedDigitSystemFont(ofSize: 72, weight: .light)])
                let symbolRange = NSString(string: string).range(of: Settings.shared.primaryCurrency.value.symbol)
                primaryString.addAttribute(.font, value: UIFont.Zap.regular, range: symbolRange)
                return primaryString
            }
            .bind(to: primaryAmountLabel.reactive.attributedText)
            .dispose(in: reactive.bag)
        
        waiterRequestViewModel.totalAmount
            .map { Settings.shared.secondaryCurrency.value.format(satoshis: $0) }
            .bind(to: secondaryAmountLabel.reactive.text)
            .dispose(in: reactive.bag)
    
        waiterRequestViewModel.tipAmount
            .map {
                let amountString = Settings.shared.primaryCurrency.value.format(satoshis: waiterRequestViewModel.amount) ?? "0"
                let tipAmountString = Settings.shared.primaryCurrency.value.format(satoshis: $0) ?? "0"
                return amountString + " + " + tipAmountString + " Tip"
            }
            .bind(to: tipDetailLabel.reactive.text)
            .dispose(in: reactive.bag)
    }
    
    func setPercentTitle(to button: UIButton, value: Int) {
        let percentString = NSMutableAttributedString(string: "\(String(value)) %\n", attributes: [.foregroundColor: UIColor.Zap.white])
        percentString.append(NSAttributedString(string: "Tip", attributes: [.foregroundColor: UIColor.Zap.gray]))
        
        button.setAttributedTitle(percentString, for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
    
        button.backgroundColor = UIColor.Zap.deepSeaBlue
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.Zap.slateBlue.cgColor
    }
    
    @IBAction private func tipButtonTapped(_ sender: UIButton) {
        var newIndex = 0
        if sender == tip2Button {
            newIndex = 1
        } else if sender == tip3Button {
            newIndex = 2
        }
        
        tip1Button.layer.borderColor = UIColor.Zap.slateBlue.cgColor
        tip2Button.layer.borderColor = UIColor.Zap.slateBlue.cgColor
        tip3Button.layer.borderColor = UIColor.Zap.slateBlue.cgColor
        
        UIView.animate(withDuration: 0.275) {
            self.tipDetailLabel.isHidden = self.waiterRequestViewModel?.selectedTipIndex == newIndex
        }
        
        if waiterRequestViewModel?.selectedTipIndex == newIndex {
            waiterRequestViewModel?.selectedTipIndex = nil
        } else {
            waiterRequestViewModel?.selectedTipIndex = newIndex
            sender.layer.borderColor = UIColor.Zap.lightningOrange.cgColor
        }
    }

    @IBAction private func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func confirm(_ sender: Any) {
        guard let waiterRequestViewModel = waiterRequestViewModel else { return }
        let waiterRequestViewController = UIStoryboard.instantiateWaiterRequestViewController(waiterRequestViewModel: waiterRequestViewModel)
        navigationController?.pushViewController(waiterRequestViewController, animated: true)
    }
}

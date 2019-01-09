//
//  Library
//
//  Created by Otto Suess on 08.01.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning

protocol ChargePresentable {
    func setupChargeButton(button: UIButton, amount: Observable<Decimal>)
    func presentChargeViewController(transactionService: TransactionService, fiatValue: Decimal, shoppingCartViewModel: ShoppingCartViewModel)
}

extension ChargePresentable where Self: UIViewController {
    func setupChargeButton(button: UIButton, amount: Observable<Decimal>) {
        Style.Button.background.apply(to: button)
        
        amount
            .map { $0 > 0 }
            .bind(to: button.reactive.isEnabled)
            .dispose(in: reactive.bag)
        
        UIView.performWithoutAnimation {
            let amount = Settings.shared.fiatCurrency.value.format(value: amount.value) ?? ""
            button.setTitle("Charge \(amount)", for: .normal)
            button.layoutIfNeeded()
        }
        
        amount
            .skip(first: 1)
            .map {
                let amount = Settings.shared.fiatCurrency.value.format(value: $0) ?? ""
                return "Charge \(amount)"
            }
            .bind(to: button.reactive.title)
            .dispose(in: reactive.bag)
    }
    
    func presentChargeViewController(transactionService: TransactionService, fiatValue: Decimal, shoppingCartViewModel: ShoppingCartViewModel) {
        let amount = Settings.shared.fiatCurrency.value.satoshis(from: fiatValue)
        let waiterRequestViewModel = WaiterRequestViewModel(amount: amount, transactionService: transactionService, shoppingCartViewModel: shoppingCartViewModel)
        let tipViewController = UIStoryboard.instantiateTipViewController(waiterRequestViewModel: waiterRequestViewModel)
        let navigationController = ZapNavigationController(rootViewController: tipViewController)
        present(navigationController, animated: true, completion: nil)
    }
}

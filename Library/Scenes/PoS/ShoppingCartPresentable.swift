//
//  Library
//
//  Created by Otto Suess on 24.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning

protocol ShoppingCartPresentable {
    func presentShoppingCart(shoppingCartViewModel: ShoppingCartViewModel)
    func presentTipViewController(transactionService: TransactionService)
    func setupPayButton(button: UIButton, amount: Observable<Decimal>)
}

extension ShoppingCartPresentable where Self: UIViewController {
    func presentShoppingCart(shoppingCartViewModel: ShoppingCartViewModel) {
        let shoppingCartViewController = UIStoryboard.instantiateShoppingCartViewController(shoppingCartViewModel: shoppingCartViewModel)
        navigationController?.pushViewController(shoppingCartViewController, animated: true)
    }
    
    func presentTipViewController(transactionService: TransactionService) {
        let waiterRequestViewModel = WaiterRequestViewModel(amount: 19, transactionService: transactionService)
        let tipViewController = UIStoryboard.instantiateTipViewController(waiterRequestViewModel: waiterRequestViewModel)
        let navigationController = ZapNavigationController(rootViewController: tipViewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    func setupPayButton(button: UIButton, amount: Observable<Decimal>) {
        amount
            .map { $0 > 0 }
            .bind(to: button.reactive.isEnabled)
            .dispose(in: reactive.bag)
        
        amount
            .map {
                let amount = Settings.shared.fiatCurrency.value.format(value: $0) ?? ""
                return "Pay \(amount)"
            }
            .bind(to: button.reactive.title)
            .dispose(in: reactive.bag)
    }
}

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
    func setupShoppingCartBarButton(shoppingCartViewModel: ShoppingCartViewModel, selector: Selector)
    func presentShoppingCart(shoppingCartViewModel: ShoppingCartViewModel, transactionService: TransactionService)
}

extension UIImage {
    static func imageWithLabel(label: UILabel) -> UIImage? {
        defer {
            UIGraphicsEndImageContext()
        }
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        label.layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension ShoppingCartPresentable where Self: UIViewController {
    func presentShoppingCart(shoppingCartViewModel: ShoppingCartViewModel, transactionService: TransactionService) {
        let shoppingCartViewController = UIStoryboard.instantiateShoppingCartViewController(shoppingCartViewModel: shoppingCartViewModel, transactionService: transactionService)
        navigationController?.pushViewController(shoppingCartViewController, animated: true)
    }
    
    func image(count: Int) -> UIImage? {
        defer {
            UIGraphicsEndImageContext()
        }
        let buttonSize: CGFloat = 24
        let imageSpacing: CGFloat = 5
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        label.font = UIFont.Zap.posCountFont
        label.textAlignment = .center
        label.textColor = .white
        label.text = String(count)
        label.layer.cornerRadius = buttonSize / 2
        label.clipsToBounds = true
        label.backgroundColor = UIColor.Zap.lightningOrange
        
        let circleImage = UIImage.imageWithLabel(label: label)
        
        let size = CGSize(width: buttonSize * 2 + imageSpacing, height: buttonSize)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        let circleFrame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        circleImage?.draw(in: circleFrame)
        let cartFrame = CGRect(x: buttonSize + imageSpacing, y: 1, width: buttonSize, height: buttonSize - 2)
        
        Asset.posCart.image.draw(in: cartFrame)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func setupShoppingCartBarButton(shoppingCartViewModel: ShoppingCartViewModel, selector: Selector) {
        let shoppingCartButton = UIButton(type: .custom)

        let barButton = UIBarButtonItem(customView: shoppingCartButton)
        navigationItem.rightBarButtonItem = barButton

        shoppingCartButton.addTarget(self, action: selector, for: .touchUpInside)
        
        shoppingCartViewModel.totalCount
            .observeNext { [weak self] in
                shoppingCartButton.setImage(self?.image(count: $0), for: .normal)
            }
            .dispose(in: reactive.bag)
    }
}

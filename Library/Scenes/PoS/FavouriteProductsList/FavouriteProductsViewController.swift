//
//  Library
//
//  Created by Otto Suess on 20.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning

extension UIStoryboard {
    static func instantiateFavouriteProductsViewController(transactionService: TransactionService, productsViewModel: ProductsViewModel, shoppingCartViewModel: ShoppingCartViewModel) -> ZapNavigationController {
        let productViewController = StoryboardScene.PoS.productViewController.instantiate()
        productViewController.transactionService = transactionService
        productViewController.productsViewModel = productsViewModel
        productViewController.shoppingCartViewModel = shoppingCartViewModel
        
        let navigationController = ZapNavigationController(rootViewController: productViewController)
        navigationController.tabBarItem.image = Asset.tabbarWallet.image
        navigationController.tabBarItem.title = "Favourites"

        return navigationController
    }
}

final class FavouriteProductsViewController: UIViewController, ShoppingCartPresentable {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var payButton: UIButton!
    @IBOutlet private weak var shoppingCartButton: UIBarButtonItem!

    // swiftlint:disable implicitly_unwrapped_optional
    fileprivate var productsViewModel: ProductsViewModel!
    fileprivate var shoppingCartViewModel: ShoppingCartViewModel!
    fileprivate var transactionService: TransactionService!
    // swiftlint:enable implicitly_unwrapped_optional
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Chicago Bar"
        
        Style.Button.background.apply(to: payButton)
        
        view.backgroundColor = UIColor.Zap.background
        collectionView.backgroundColor = UIColor.Zap.background
        collectionView.registerCell(FavouriteProductCollectionViewCell.self)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        navigationItem.largeTitleDisplayMode = .never

        setupPayButton(button: payButton, amount: shoppingCartViewModel.totalAmount)
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumInteritemSpacing = 10
            flowLayout.minimumLineSpacing = 10
            let border: CGFloat = 20
            let itemWidth = (collectionView.bounds.width - 2 * flowLayout.minimumInteritemSpacing - 2 * border) / 3
            flowLayout.itemSize = CGSize(
                width: itemWidth,
                height: itemWidth)
            
            collectionView.contentInset = UIEdgeInsets(top: border, left: border, bottom: border, right: border)
        }
    }
    
    @IBAction private func presentTipViewController(_ sender: Any) {
        presentTipViewController(transactionService: transactionService)
    }
    
    @IBAction private func presentShoppingCart(_ sender: UIButton) {
        presentShoppingCart(shoppingCartViewModel: shoppingCartViewModel)
    }
}

extension FavouriteProductsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = productsViewModel.favourites[indexPath.row]
        shoppingCartViewModel.addSingle(product: product)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? FavouriteProductCollectionViewCell {
            cell.animateSelection()
        }
    }
}

extension FavouriteProductsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productsViewModel.favourites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FavouriteProductCollectionViewCell = collectionView.dequeueCellForIndexPath(indexPath)
        
        let product = productsViewModel.favourites[indexPath.row]
        let count = shoppingCartViewModel.count(of: product)
        cell.setItem(product: product, count: count)
        
        return cell
    }
}

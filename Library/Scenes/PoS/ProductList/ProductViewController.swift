//
//  Library
//
//  Created by Otto Suess on 20.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Lightning

extension UIStoryboard {
    static func instantiateProductViewController(transactionService: TransactionService) -> ZapNavigationController {
        let productViewController = StoryboardScene.PoS.productViewController.instantiate()
        productViewController.transactionService = transactionService

        let navigationController = ZapNavigationController(rootViewController: productViewController)
        
        navigationController.tabBarItem.image = Asset.tabbarWallet.image
        navigationController.tabBarItem.title = "Favourites"

        return navigationController
    }
}

final class ProductViewController: UIViewController {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var payButton: UIButton!
    @IBOutlet private weak var shoppingCartButton: UIBarButtonItem!

    private let productsViewModel = ProductsViewModel()
    private let shoppingCartViewModel: ShoppingCartViewModel
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        shoppingCartViewModel = ShoppingCartViewModel(products: productsViewModel.items)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        shoppingCartViewModel = ShoppingCartViewModel(products: productsViewModel.items)
        super.init(coder: aDecoder)
    }
    
    fileprivate var transactionService: TransactionService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Chicago Bar"
        
        Style.Button.background.apply(to: payButton)
        
        view.backgroundColor = UIColor.Zap.background
        collectionView.backgroundColor = UIColor.Zap.background
        collectionView.registerCell(ProductCollectionViewCell.self)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        navigationItem.largeTitleDisplayMode = .never
        
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
        guard let transactionService = transactionService else { return }
        let waiterRequestViewModel = WaiterRequestViewModel(amount: 19, transactionService: transactionService)
        let tipViewController = UIStoryboard.instantiateTipViewController(waiterRequestViewModel: waiterRequestViewModel)
        let navigationController = ZapNavigationController(rootViewController: tipViewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction private func presentShoppingCart(_ sender: Any) {
        let shoppingCartViewController = UIStoryboard.instantiateShoppingCartViewController(shoppingCartViewModel: shoppingCartViewModel)
        navigationController?.pushViewController(shoppingCartViewController, animated: true)
    }
    
    private func updatePayButtonText() {
        let title = "Pay \(shoppingCartViewModel.sum)"
        payButton.setTitle(title, for: .normal)
    }
}

extension ProductViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = productsViewModel.items[indexPath.row]
        shoppingCartViewModel.addSingle(product: product)
        updatePayButtonText()
        
        if let cell = collectionView.cellForItem(at: indexPath) as? ProductCollectionViewCell {
            cell.animateSelection()
        }
    }
}

extension ProductViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productsViewModel.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ProductCollectionViewCell = collectionView.dequeueCellForIndexPath(indexPath)
        
        let product = productsViewModel.items[indexPath.row]
        let count = shoppingCartViewModel.count(of: product)
        cell.item = (product, count)
        return cell
    }
}

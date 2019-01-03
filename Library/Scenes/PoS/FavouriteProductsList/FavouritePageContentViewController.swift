//
//  Library
//
//  Created by Otto Suess on 28.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static func instantiateFavouritePageContentViewController(productsViewModel: ProductsViewModel, shoppingCartViewModel: ShoppingCartViewModel, pageIndex: Int) -> FavouritePageContentViewController {
        let viewController = StoryboardScene.PoS.favouritePageContentViewController.instantiate()
        
        viewController.productsViewModel = productsViewModel
        viewController.shoppingCartViewModel = shoppingCartViewModel
        viewController.pageIndex = pageIndex
        
        return viewController
    }
}

final class FavouritePageContentViewController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!

    fileprivate var pageIndex = 0
    // swiftlint:disable implicitly_unwrapped_optional
    fileprivate var productsViewModel: ProductsViewModel!
    fileprivate var shoppingCartViewModel: ShoppingCartViewModel!
    // swiftlint:enable implicitly_unwrapped_optional
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.Zap.background
        collectionView.backgroundColor = UIColor.Zap.background
        collectionView.registerCell(FavouriteProductCollectionViewCell.self)
        
        collectionView.dataSource = self
        collectionView.delegate = self

        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumInteritemSpacing = 20
            flowLayout.minimumLineSpacing = 20
            let border: CGFloat = 20
            let itemWidth = (collectionView.bounds.width - 2 * flowLayout.minimumInteritemSpacing - 2 * border) / 3
            flowLayout.itemSize = CGSize(
                width: itemWidth,
                height: itemWidth)
            
            collectionView.contentInset = UIEdgeInsets(top: border, left: border, bottom: border, right: border)
        }
    }
}

extension FavouritePageContentViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = productsViewModel.favourites[pageIndex][indexPath.row]
        shoppingCartViewModel.addSingle(product: product)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? FavouriteProductCollectionViewCell {
            cell.animateSelection()
        }
    }
}

extension FavouritePageContentViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productsViewModel.favourites[pageIndex].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FavouriteProductCollectionViewCell = collectionView.dequeueCellForIndexPath(indexPath)
        
        let product = productsViewModel.favourites[pageIndex][indexPath.row]
        let count = shoppingCartViewModel.count(of: product)
        cell.setItem(product: product, count: count)
        
        return cell
    }
}

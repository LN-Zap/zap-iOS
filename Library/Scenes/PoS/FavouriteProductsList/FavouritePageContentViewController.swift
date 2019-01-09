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
            let spacing: CGFloat = UIScreen.main.bounds.width <= 320 ? 5 : 20
            let border: CGFloat = 20
            let itemsPerLine: CGFloat = 3
            
            flowLayout.minimumInteritemSpacing = spacing
            flowLayout.minimumLineSpacing = spacing
            
            let itemWidth = (UIScreen.main.bounds.width - (itemsPerLine - 1) * spacing - 2 * border) / itemsPerLine
            flowLayout.itemSize = CGSize(
                width: itemWidth,
                height: itemWidth)
            
            collectionView.contentInset = UIEdgeInsets(top: 0, left: border, bottom: border, right: border)
        }
    }
}

extension FavouritePageContentViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let product = productsViewModel.favourites[pageIndex].items[indexPath.row] as? Product else { return }
        shoppingCartViewModel.addSingle(product: product)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? FavouriteProductCollectionViewCell {
            cell.animateSelection()
        }
    }
}

extension FavouritePageContentViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productsViewModel.favourites[pageIndex].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FavouriteProductCollectionViewCell = collectionView.dequeueCellForIndexPath(indexPath)
        
        if let product = productsViewModel.favourites[pageIndex].items[indexPath.row] as? Product {
            let count = shoppingCartViewModel.count(of: product)
            cell.setItem(product: product, count: count)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FavouriteSectionHeader", for: indexPath) as? FavouriteSectionHeader else { fatalError("could not deque FavouriteSectionHeader") }
        sectionHeader.setTitle(productsViewModel.favourites[pageIndex].name)
        return sectionHeader
    }
}

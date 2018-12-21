//
//  Library
//
//  Created by Otto Suess on 20.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

let items: [Groupable] = [
    Product(name: "Bier", price: 3.50),
    Product(name: "Bier 2", price: 2.75),
    Product(name: "Pils", price: 1.30),
    Product(name: "TS 1", price: 0.01),
    Product(name: "TS 2", price: 5),
    Product(name: "TS 3", price: 1),
    Product(name: "TS 21", price: 2),
    Product(name: "TS 22", price: 100),
    Product(name: "TS 23", price: 15)
]

final class ProductViewController: UIViewController {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var payButton: UIButton!
    @IBOutlet private weak var shoppingCartButton: UIBarButtonItem!
    
    private let shoppingCartViewModel = ShoppingCartViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Chicago Bar"
        
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
//        let waiterRequestViewModel = WaiterRequestViewModel(amount: 19, transactionService: nil)
//        let tipViewController = UIStoryboard.instantiateTipViewController(waiterRequestViewModel: waiterRequestViewModel)
//        present(tipViewController, animated: true, completion: nil)
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
        guard let product = items[indexPath.row] as? Product else { return }
        shoppingCartViewModel.addSingle(product: product)
        updatePayButtonText()
        
        let cell = collectionView.cellForItem(at: indexPath)
        
        cell?.backgroundColor = UIColor.Zap.lightningOrange
        UIView.animate(withDuration: 0.3) {
            cell?.backgroundColor = UIColor.Zap.background
        }
    }
}

extension ProductViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ProductCollectionViewCell = collectionView.dequeueCellForIndexPath(indexPath)
        cell.product = items[indexPath.row] as? Product
        return cell
    }
}

//
//  Zap
//
//  Created by Otto Suess on 09.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import UIKit

extension UIStoryboard {
    static func instantiateConfirmMnemonicViewController(confirmMnemonicViewModel: ConfirmMnemonicViewModel, walletConfirmed: @escaping () -> Void) -> ConfirmMnemonicViewController {
        let viewController = Storyboard.createWallet.instantiate(viewController: ConfirmMnemonicViewController.self)
        viewController.confirmViewModel = confirmMnemonicViewModel
        viewController.walletConfirmed = walletConfirmed
        return viewController
    }
}

private let itemWitdh: CGFloat = 140

final class ConfirmMnemonicViewController: UIViewController {
    
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    fileprivate var confirmViewModel: ConfirmMnemonicViewModel?
    fileprivate var walletConfirmed: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Confirm Seed"

        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        
        Style.label.apply(to: descriptionLabel) {
            $0.textColor = .white
        }
        
        descriptionLabel.text = "Enter your key."
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.minimumLineSpacing = 10
            flowLayout.itemSize = CGSize(width: itemWitdh, height: collectionView.bounds.height)
        }
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    var currentCell = 0
    
    private func selectNextCell() {
        guard let confirmViewModel = confirmViewModel else { return }
        
        if currentCell >= confirmViewModel.wordList.count - 1 {
            walletConfirmed?()
            confirmViewModel.didVerifyMnemonic()
            return
        }
        
        currentCell += 1
        
        let indexPath = IndexPath(item: currentCell, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        for cell in collectionView.visibleCells {
            guard let cell = cell as? ConfirmMnemonicCollectionViewCell else { continue }
            cell.isActiveCell = false
        }
        
        if let cell = collectionView.cellForItem(at: indexPath) as? ConfirmMnemonicCollectionViewCell {
            cell.isActiveCell = true
        }
    }
}

extension ConfirmMnemonicViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return confirmViewModel?.wordList.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ConfirmMnemonicCollectionViewCell = collectionView.dequeueCellForIndexPath(indexPath)
        cell.confirmWordViewModel = confirmViewModel?.wordList[indexPath.item]
        
        cell.wordConfirmedCallback = selectNextCell
        
        if indexPath.row == currentCell {
            cell.isActiveCell = true
        }
        
        return cell
    }
}

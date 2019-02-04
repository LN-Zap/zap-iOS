//
//  Zap
//
//  Created by Otto Suess on 09.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Lightning
import UIKit

private let itemWitdh: CGFloat = 140

final class ConfirmMnemonicViewController: UIViewController {
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // swiftlint:disable implicitly_unwrapped_optional
    fileprivate var confirmViewModel: ConfirmMnemonicViewModel!
    fileprivate var connectWallet: ((WalletConfiguration) -> Void)!
    // swiftlint:enable implicitly_unwrapped_optional

    static func instantiate(confirmMnemonicViewModel: ConfirmMnemonicViewModel, connectWallet: @escaping (WalletConfiguration) -> Void) -> ConfirmMnemonicViewController {
        let viewController = StoryboardScene.CreateWallet.confirmMnemonicViewController.instantiate()
        viewController.confirmViewModel = confirmMnemonicViewModel
        viewController.connectWallet = connectWallet
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.Scene.ConfirmMnemonic.title

        view.backgroundColor = UIColor.Zap.background
    
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        
        Style.Label.custom(color: .white).apply(to: descriptionLabel)
        
        descriptionLabel.text = L10n.Scene.ConfirmMnemonic.description
        
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
            connectWallet?(confirmViewModel.configuration)
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

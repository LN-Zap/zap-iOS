//
//  Library
//
//  Created by 0 on 09.04.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Bond
import Foundation
import SwiftBTC

final class ChannelQRCodeScannerViewController: QRCodeScannerViewController {
    enum PeerCell {
        case loading
        case peer(SuggestedPeers.Currency.Peer)
    }

    private let suggestedPeers = MutableObservableArray<PeerCell>([.loading])

    private let network: Network?

    init(strategy: QRCodeScannerStrategy, network: Network?) {
        self.network = network
        super.init(strategy: strategy)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()

        SuggestedPeers.load(for: network ?? .mainnet) { [suggestedPeers] in
            suggestedPeers.replace(with: $0.map { PeerCell.peer($0) })
        }
    }

    private func setupLayout() {
        let collectionViewHeith: CGFloat = 95

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: 97, height: collectionViewHeith)
        layout.scrollDirection = .horizontal

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.registerCell(SuggestedPeerCell.self)
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        view.addAutolayoutSubview(collectionView)

        let titleLabel = UILabel(frame: .zero)
        titleLabel.text = L10n.Scene.OpenChannel.SuggestedPeers.title
        titleLabel.textAlignment = .center
        Style.Label.body.apply(to: titleLabel)
        view.addAutolayoutSubview(titleLabel)

        suggestedPeers.bind(to: collectionView) { peers, indexPath, collectionView -> UICollectionViewCell in
            let cell: SuggestedPeerCell = collectionView.dequeueCellForIndexPath(indexPath)
            cell.cellType = peers[indexPath.item]
            return cell
        }

        NSLayoutConstraint.activate([
            // collection view
            collectionView.heightAnchor.constraint(equalToConstant: collectionViewHeith),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pasteButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 15),
            // label
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5)
        ])
    }
}

extension ChannelQRCodeScannerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if case .peer(let peer) = suggestedPeers[indexPath.row] {
            let nodeURI = "\(peer.pubkey)@\(peer.host)"
            tryPresentingViewController(for: nodeURI)
        }
    }
}

//
//  Library
//
//  Created by 0 on 09.04.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import UIKit

class SuggestedPeerCell: UICollectionViewCell {
    @IBOutlet private weak var peerImageView: UIImageView!
    @IBOutlet private weak var aliasLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()

        peerImageView.contentMode = .scaleAspectFill
        peerImageView.layer.cornerRadius = 12
        peerImageView.backgroundColor = UIColor.Zap.seaBlue

        backgroundColor = .clear

        Style.Label.footnote.apply(to: aliasLabel)
        aliasLabel.textColor = UIColor.Zap.white
    }

    var cellType: ChannelQRCodeScannerViewController.PeerCell? {
        didSet {
            guard let cellType = cellType else { return }

            switch cellType {
            case .loading:
                peerImageView.image = nil
                aliasLabel.text = " "
                activityIndicator.isHidden = false
            case .peer(let peer):
                peerImageView.download(from: peer.image)
                aliasLabel.text = peer.nickname
                activityIndicator.isHidden = true
            }
        }
    }
}

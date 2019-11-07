//
//  Library
//
//  Created by 0 on 11.10.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Lightning

protocol NodeHeaderViewDelegate: class {
    func manageNodesButtonTapped()
}

final class NodeHeaderView: UIView {
    @IBOutlet private weak var nodeAliasLabel: UILabel!
    @IBOutlet private weak var torLabel: PaddingLabel!
    @IBOutlet private weak var networkLabel: PaddingLabel!
    @IBOutlet private weak var backgroundView: UIView!
    
    weak var delegate: NodeHeaderViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundView.backgroundColor = UIColor.Zap.background
        
        // network label
        setup(label: networkLabel)
        setup(label: torLabel)

        networkLabel.backgroundColor = UIColor.Zap.invisibleGray
        torLabel.backgroundColor = UIColor(red: 125.0 / 255.0, green: 70.0 / 255.0, blue: 153.0 / 255.0, alpha: 1.0)
        // node alias label
        nodeAliasLabel.text = nil
        Style.Label.title.apply(to: nodeAliasLabel)

        let imageAttachment = NSTextAttachment()
        imageAttachment.image = Asset.nodeTor.image
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        torLabel.attributedText = attachmentString
    }
    
    private func setup(label: PaddingLabel) {
        label.edgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        label.layer.cornerRadius = 13
        label.clipsToBounds = true
        label.layer.masksToBounds = true
        label.text = nil
        label.textColor = UIColor.Zap.white
        label.textAlignment = .center
    }
    
    @IBAction private func displayManageNodes(_ sender: Any) {
        delegate?.manageNodesButtonTapped()
    }
    
    func update(lightningService: LightningService) {
        if case .remote(let credentials) = lightningService.connection,
            credentials.host.isOnion {
            // don't remove label if it has an .onion url
        } else {
            torLabel.removeFromSuperview()
        }
        
        lightningService.infoService.network
            .map { $0?.localized }
            .bind(to: networkLabel.reactive.text)
            .dispose(in: reactive.bag)
        lightningService.infoService.info
            .map { $0?.alias }
            .bind(to: nodeAliasLabel.reactive.text)
            .dispose(in: reactive.bag)
    }
}

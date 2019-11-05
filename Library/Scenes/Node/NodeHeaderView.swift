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
    @IBOutlet private weak var networkLabel: PaddingLabel!
    @IBOutlet private weak var backgroundView: UIView!
    
    weak var delegate: NodeHeaderViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundView.backgroundColor = UIColor.Zap.background
        
        // network label
        networkLabel.edgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        networkLabel.backgroundColor = UIColor.Zap.invisibleGray
        networkLabel.layer.cornerRadius = 13
        networkLabel.clipsToBounds = true
        networkLabel.layer.masksToBounds = true
        networkLabel.text = nil
        networkLabel.textColor = UIColor.Zap.white
        
        // node alias label
        nodeAliasLabel.text = nil
        Style.Label.title.apply(to: nodeAliasLabel)
    }
    
    @IBAction private func displayManageNodes(_ sender: Any) {
        delegate?.manageNodesButtonTapped()
    }
    
    func update(infoService: InfoService) {
        infoService.network
            .map { $0?.localized }
            .bind(to: networkLabel.reactive.text)
            .dispose(in: reactive.bag)
        infoService.info
            .map { $0?.alias }
            .bind(to: nodeAliasLabel.reactive.text)
            .dispose(in: reactive.bag)
    }
}

//
//  Zap
//
//  Created by Otto Suess on 05.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

protocol ChannelCellDelegate: class {
    func closeChannelButtonTapped(channelViewModel: ChannelViewModel)
    func fundingTransactionTxIdButtonTapped(channelViewModel: ChannelViewModel)
}

class ChannelCell: BondCollectionViewCell {
    @IBOutlet private weak var stackView: UIStackView!
    
    private var gradientLayer: CAGradientLayer?

    weak var delegate: ChannelCellDelegate?
    
    var channelViewModel: ChannelViewModel? {
        didSet {
            guard let channelViewModel = channelViewModel else { return }
            
            let detailViewModel = channelViewModel.detailViewModel
            
            detailViewModel.closeChannel = closeChannel
            detailViewModel.presentBlockExplorer = presentBlockExplorer
            
            updateGradient()
            stackView.set(elements: detailViewModel.elements)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        stackView.clear()
        gradientLayer?.removeFromSuperlayer()
    }
    
    private func updateGradient() {
        self.gradientLayer?.removeFromSuperlayer()
        
        guard let channelViewModel = channelViewModel else { return }
        let color = channelViewModel.color.value.verified
        
        layer.borderColor = color.darker.cgColor

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [color.cgColor, color.darker.cgColor]
        layer.insertSublayer(gradientLayer, at: 0)
        self.gradientLayer = gradientLayer
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        stackView.spacing = 14
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        layer.cornerRadius = 11
        layer.borderWidth = 1
        layer.masksToBounds = true
    }
    
    private func presentBlockExplorer() {
        guard let viewModel = channelViewModel else { return }
        delegate?.fundingTransactionTxIdButtonTapped(channelViewModel: viewModel)
    }
    
    @IBAction private func closeChannel() {
        guard let viewModel = channelViewModel else { return }
        delegate?.closeChannelButtonTapped(channelViewModel: viewModel)
    }
}

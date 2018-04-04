//
//  Zap
//
//  Created by Otto Suess on 08.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import ReactiveKit

final class SyncView: UIView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var backgroundView: UIView!
    
    var viewModel: ViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            
            let blockInfo = combineLatest(viewModel.blockChainHeight, viewModel.blockHeight) { ($0, $1) }
            
            blockInfo
                .map { blockChainHeight, blockHeight in
                    guard
                        let blockChainHeight = blockChainHeight,
                        blockChainHeight != 0
                        else { return "0.0%" }
                    
                    return "\(Float(blockHeight) / Float(blockChainHeight) * 100)%"
                }
                .bind(to: dateLabel.reactive.text)
                .dispose(in: reactive.bag)
            
            blockInfo
                .map { blockChainHeight, blockHeight in
                    guard
                        let blockChainHeight = blockChainHeight,
                        blockChainHeight != 0
                        else { return 0 }
                    
                    return Float(blockHeight) / Float(blockChainHeight)
                }
                .bind(to: progressView.reactive.progress)
                .dispose(in: reactive.bag)
        }
    }
    
    private func syncView() -> UIView? {
        let views = Bundle.main.loadNibNamed("SyncView", owner: self, options: nil)
        guard let content = views?.first as? UIView else { return nil }
        
        translatesAutoresizingMaskIntoConstraints = false
        content.translatesAutoresizingMaskIntoConstraints = false
        
        return content
    }
    
    private func setup() {
        guard let content = syncView() else { return }
        addSubview(content)
        
        let views = ["content": content]
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[content]|", options: [], metrics: nil, views: views)
        addConstraints(horizontalConstraints)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[content]|", options: [], metrics: nil, views: views)
        addConstraints(verticalConstraints)
        
        backgroundView.layer.cornerRadius = 8
        backgroundView.backgroundColor = Color.darkBackground
        
        Style.label.apply(to: titleLabel, dateLabel)
        
        titleLabel.text = "Syncing"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}

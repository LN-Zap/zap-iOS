//
//  Zap
//
//  Created by Otto Suess on 11.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

public final class SegmentButton: UIButton {
    public enum Alignment {
        case vertical
        case horizontal
    }
    
    private weak var selectedLineView: UIView?
    
    public var alignment = Alignment.vertical {
        didSet {
            setNeedsLayout()
        }
    }
    
    var lineFrame: CGRect {
        let lineHeight: CGFloat = 3
        return CGRect(x: 0, y: bounds.height - lineHeight, width: bounds.width, height: lineHeight)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        titleLabel?.font = UIFont.zap.light.withSize(10)
        
        tintColor = UIColor.zap.lightGrey
        alignImageAndTitleVertically()
     
        setTitleColor(UIColor.zap.black, for: .selected)
        setTitleColor(UIColor.zap.lightGrey, for: .normal)
        
        let selectedLineView = UIView(frame: CGRect.zero)
        selectedLineView.backgroundColor = UIColor.zap.black
        selectedLineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(selectedLineView)
        
        NSLayoutConstraint.activate([
            selectedLineView.heightAnchor.constraint(equalToConstant: 3),
            selectedLineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            selectedLineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            selectedLineView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        selectedLineView.isHidden = true
        self.selectedLineView = selectedLineView
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        switch alignment {
        case .vertical:
            alignImageAndTitleVertically()
        case .horizontal:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        }
    }
    
    public override var isSelected: Bool {
        didSet {
            selectedLineView?.isHidden = !isSelected
            tintColor = isSelected ? UIColor.zap.black : UIColor.zap.lightGrey
        }
    }
}

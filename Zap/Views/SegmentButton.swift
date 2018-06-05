//
//  Zap
//
//  Created by Otto Suess on 11.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class SegmentButton: UIButton {
    
    private weak var selectedLineView: UIView?
    
    var lineFrame: CGRect {
        let lineHeight: CGFloat = 3
        return CGRect(x: 0, y: bounds.height - lineHeight, width: bounds.width, height: lineHeight)
    }
    
    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)

        titleLabel?.font = UIFont.zap.light.withSize(10)
        
        tintColor = UIColor.zap.lightGrey
        alignImageAndTitleVertically()
     
        setTitleColor(UIColor.zap.black, for: .selected)
        setTitleColor(UIColor.zap.lightGrey, for: .normal)
        
        let selectedLineView = UIView(frame: lineFrame)
        selectedLineView.backgroundColor = UIColor.zap.black
        addSubview(selectedLineView)
        selectedLineView.isHidden = true
        self.selectedLineView = selectedLineView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        alignImageAndTitleVertically()
    }
    
    override var isSelected: Bool {
        didSet {
            selectedLineView?.isHidden = !isSelected
            tintColor = isSelected ? UIColor.zap.black : UIColor.zap.lightGrey
        }
    }
}

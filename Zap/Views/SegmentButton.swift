//
//  Zap
//
//  Created by Otto Suess on 11.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

final class SegmentButton: UIButton {
    
    private weak var selectedLineView: UIView?
    
    var lineFrame: CGRect {
        let lineHeight: CGFloat = 3
        return CGRect(x: 0, y: bounds.height - lineHeight, width: bounds.width, height: lineHeight)
    }
    
    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)

        titleLabel?.font = Font.light.withSize(10)
        
        tintColor = Color.disabled
        alignImageAndTitleVertically()
     
        setTitleColor(Color.text, for: .selected)
        setTitleColor(Color.disabled, for: .normal)
        
        let selectedLineView = UIView(frame: lineFrame)
        selectedLineView.backgroundColor = Color.text
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
            tintColor = isSelected ? Color.text : Color.disabled
        }
    }
}

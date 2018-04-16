//
//  Zap
//
//  Created by Otto Suess on 13.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class AddressView: UIStackView {
    private let label1 = UILabel()
    private let label2 = UILabel()
    private let label3 = UILabel()
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        self.axis = .horizontal
        
        self.addArrangedSubview(label1)
        self.addArrangedSubview(label2)
        self.addArrangedSubview(label3)
        
        Style.label.apply(to: label1, label2, label3) {
            $0.font = $0.font.withSize(14)
        }
        
        label2.minimumScaleFactor = 0.001
        label2.adjustsFontSizeToFitWidth = true
        
        label1.setContentHuggingPriority(UILayoutPriority(rawValue: 750), for: .horizontal)
        label2.setContentHuggingPriority(UILayoutPriority(rawValue: 750), for: .horizontal)
        label3.setContentHuggingPriority(UILayoutPriority(rawValue: 750), for: .horizontal)
        
        label1.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 750), for: .horizontal)
        label2.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 10), for: .horizontal)
        label3.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 750), for: .horizontal)
    }
    
    var address: String? {
        didSet {
            guard let address = address else { return }
            
            let firstIndex = address.index(address.startIndex, offsetBy: 6)
            let secondIndex = address.index(address.endIndex, offsetBy: -6)
            
            label1.text = String(address[address.startIndex..<firstIndex])
            label2.text = String(address[firstIndex..<secondIndex])
            label3.text = String(address[secondIndex..<address.endIndex])
        }
    }
}

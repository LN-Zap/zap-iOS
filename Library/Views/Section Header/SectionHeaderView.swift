//
//  Zap
//
//  Created by Otto Suess on 08.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

final class SectionHeaderView: UIView {
    
    @IBOutlet private weak var backgroundView: UIView! {
        didSet {
            backgroundView.backgroundColor = .white
        }
    }
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            Style.label.apply(to: titleLabel)
            titleLabel.font = UIFont.zap.bold.withSize(10)
            titleLabel.textColor = UIColor.zap.black
        }
    }
    
    static var instanceFromNib: SectionHeaderView {
        guard let view = UINib(nibName: "SectionHeaderView", bundle: Bundle.library)
            .instantiate(withOwner: nil, options: nil)[0] as? SectionHeaderView
            else { fatalError("Could not initialize SectionHeaderView.") }
        return view
    }
    
    var title: String? {
        set {
            titleLabel.text = newValue
        }
        get {
            return titleLabel.text
        }
    }
}

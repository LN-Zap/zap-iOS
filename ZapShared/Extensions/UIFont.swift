//
//  Zap
//
//  Created by Otto Suess on 23.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

public extension UIFont {
    // swiftlint:disable:next type_name
    public enum zap {
        public static let light = UIFont(name: "Roboto-Light", size: UIFont.labelFontSize) ?? UIFont.systemFont(ofSize: UIFont.labelFontSize)
        public static let bold = UIFont(name: "Roboto-Bold", size: UIFont.labelFontSize) ?? UIFont.systemFont(ofSize: UIFont.labelFontSize)
    }
}

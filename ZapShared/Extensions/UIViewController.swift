//
//  Zap
//
//  Created by Otto Suess on 27.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

extension UIViewController {
    enum TitleTextStyle {
        case light
        case dark
    }
    
    var titleTextStyle: TitleTextStyle {
        get {
            guard let color = navigationController?.navigationBar.titleTextAttributes?[.foregroundColor] as? UIColor else { return .light }
            return color == UIColor.zap.black ? .dark : .light
        }
        set {
            let newColor = newValue == .light ? UIColor.white : UIColor.zap.black
            navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.zap.light.withSize(20), .foregroundColor: newColor]
        }
    }
}

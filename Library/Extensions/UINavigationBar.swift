//
//  Library
//
//  Created by Otto Suess on 10.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

extension UINavigationBar {
    enum TitleTextStyle {
        case light
        case dark
    }
    
    var titleTextStyle: TitleTextStyle {
        get {
            guard let color = titleTextAttributes?[.foregroundColor] as? UIColor else { return .light }
            return color == UIColor.zap.black ? .dark : .light
        }
        set {
            let newColor = newValue == .light ? UIColor.white : UIColor.zap.black
            titleTextAttributes = [.font: UIFont.zap.light.withSize(20), .foregroundColor: newColor]
        }
    }
}

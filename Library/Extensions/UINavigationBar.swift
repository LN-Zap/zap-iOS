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
            return color == UIColor.Zap.black ? .dark : .light
        }
        set {
            let newColor = newValue == .light ? UIColor.white : UIColor.Zap.black
            titleTextAttributes = [.font: UIFont.Zap.light.withSize(20), .foregroundColor: newColor]
        }
    }
}

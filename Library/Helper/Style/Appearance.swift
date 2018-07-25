//
//  Zap
//
//  Created by Otto Suess on 21.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

enum Appearance {
    static func setup() {
        // UINavigationBar
        UINavigationBar.appearance().largeTitleTextAttributes = [.font: UIFont.zap.light.withSize(25)]
        UINavigationBar.appearance().titleTextAttributes = [.font: UIFont.zap.light.withSize(20), .foregroundColor: UIColor.white]
        
        // UIBarButtonItem
        UIBarButtonItem.appearance().setTitleTextAttributes([.font: UIFont.zap.light], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([.font: UIFont.zap.light], for: .disabled)
        
        // Search Bar Font
        let searchBarAttributes = [NSAttributedStringKey.font.rawValue: UIFont.zap.light, NSAttributedStringKey.foregroundColor.rawValue: UIColor.zap.black]
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = searchBarAttributes
        UITextField.appearance().backgroundColor = .clear
    }
}

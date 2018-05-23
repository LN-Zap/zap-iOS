//
//  Zap
//
//  Created by Otto Suess on 21.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

struct Appearance {
    static func setup() {
        // UINavigationBar
        UINavigationBar.appearance().largeTitleTextAttributes = [.font: Font.light.withSize(25)]
        UINavigationBar.appearance().titleTextAttributes = [.font: Font.light.withSize(20), .foregroundColor: UIColor.white]
        
        // UIBarButtonItem
        UIBarButtonItem.appearance().setTitleTextAttributes([.font: Font.light], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([.font: Font.light], for: .disabled)
        
        // Search Bar Font
        let searchBarAttributes = [NSAttributedStringKey.font.rawValue: Font.light, NSAttributedStringKey.foregroundColor.rawValue: UIColor.zap.text]
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = searchBarAttributes
        UITextField.appearance().backgroundColor = .clear
    }
}

//
//  Zap
//
//  Created by Otto Suess on 21.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

enum Appearance {
    enum Constants {
        static let modalCornerRadius: CGFloat = 14
    }
    
    static func setup() {
        // UINavigationBar
        UINavigationBar.appearance().largeTitleTextAttributes = [.font: UIFont.Zap.light.withSize(40), .foregroundColor: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = [.font: UIFont.Zap.light.withSize(20), .foregroundColor: UIColor.white]
        UINavigationBar.appearance().barStyle = .black
        
        // UIBarButtonItem
        UIBarButtonItem.appearance().setTitleTextAttributes([.font: UIFont.Zap.light], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([.font: UIFont.Zap.light], for: .disabled)
        
        // Search Bar Font
        let searchBarAttributes = [NSAttributedString.Key.font: UIFont.Zap.light, NSAttributedString.Key.foregroundColor: UIColor.Zap.black]
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = searchBarAttributes
        UITextField.appearance().backgroundColor = .clear
    }
}

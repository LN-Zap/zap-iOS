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

        UITextField.appearance().backgroundColor = .clear
    }
}

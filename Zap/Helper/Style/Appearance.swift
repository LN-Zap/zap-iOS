//
//  Zap
//
//  Created by Otto Suess on 21.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

struct Appearance {
    static func setup() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.font: Font.light.withSize(25)]
        UINavigationBar.appearance().titleTextAttributes = [.font: Font.light]
        UIBarButtonItem.appearance().setTitleTextAttributes([.font: Font.light], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([.font: Font.light], for: .disabled)
    }
}

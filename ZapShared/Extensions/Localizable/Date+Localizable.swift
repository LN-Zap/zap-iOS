//
//  Zap
//
//  Created by Otto Suess on 12.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

extension Date: Localizable {

    var localized: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateStyle = .long
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter.string(from: self)
    }
}

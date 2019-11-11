//
//  Zap
//
//  Created by Otto Suess on 23.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

extension String {
    func starts(with prefixes: [String]) -> Bool {
        for prefix in prefixes where starts(with: prefix) {
            return true
        }
        return false
    }
    
    private static var quotes: (String, String) {
        guard
            let bQuote = Locale.current.quotationBeginDelimiter,
            let eQuote = Locale.current.quotationEndDelimiter
            else { return ("\"", "\"") }
        
        return (bQuote, eQuote)
    }
    
    var quoted: String {
        let (bQuote, eQuote) = String.quotes
        return bQuote + self + eQuote
    }
}

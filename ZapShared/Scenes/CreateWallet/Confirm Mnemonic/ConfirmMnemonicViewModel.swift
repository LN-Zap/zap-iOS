//
//  Zap
//
//  Created by Otto Suess on 09.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

private let requiredWordCount = 6

struct ConfirmWordViewModel {
    let word: String
    let index: Int
}

final class ConfirmMnemonicViewModel {
    let wordList: [ConfirmWordViewModel]

    init(aezeed: [String]) {
        var randomIndices = [Int]()
        while randomIndices.count < requiredWordCount {
            let randomNumber = Int(arc4random_uniform(UInt32(aezeed.count)))
            if !randomIndices.contains(randomNumber) {
                randomIndices.append(randomNumber)
            }
        }
        
        randomIndices.sort()
        
        wordList = randomIndices.map { ConfirmWordViewModel(word: aezeed[$0], index: $0) }
    }
    
    func didVerifyMnemonic() {
        fatalError("not implemented")
    }
}

//
//  Zap
//
//  Created by Otto Suess on 09.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

let WORDLIST = [
    "print",
    "teach",
    "burger",
    "rack",
    "eyebrow",
    "sniff",
    "nose",
    "code",
    "web",
    "month",
    "trial",
    "gap",
    "gap",
    "employ",
    "cabin",
    "start",
    "consider",
    "input",
    "manage",
    "sentence",
    "moon",
    "hint",
    "poverty",
    "budget"
]

final class MnemonicViewModel {
    private let aezeed = WORDLIST
    private let wallet: WalletProtocol
    
    var confirmMnemonicViewModel: ConfirmMnemonicViewModel {
        return ConfirmMnemonicViewModel(aezeed: aezeed)
    }
    
    var pageWords: [[MnemonicWord]] {
        let maxWordCount = 6
        var subArrays = [[String]]()
        var array = aezeed
        
        while !array.isEmpty {
            let prefix = array.prefix(maxWordCount)
            subArrays.append(Array(prefix))
            array.removeFirst(maxWordCount)
        }
        
        var index = 0
        return subArrays.map {
            $0.map {
                defer { index += 1 }
                return MnemonicWord(index: index, word: $0)
            }
        }
    }
    
    init(walletUnlocker: WalletProtocol) {
        self.wallet = walletUnlocker
    }
}

struct MnemonicWord {
    let index: Int
    let word: String
}

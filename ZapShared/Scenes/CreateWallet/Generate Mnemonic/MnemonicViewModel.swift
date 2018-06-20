//
//  Zap
//
//  Created by Otto Suess on 09.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

final class MnemonicViewModel {
    private let wallet: WalletProtocol
    private var aezeed: [String]? {
        didSet {
            guard let aezeed = aezeed else { return }
            updatePageWords(with: aezeed)
        }
    }
    
    let pageWords = Observable<[[MnemonicWord]]?>(nil)
    
    var confirmMnemonicViewModel: ConfirmMnemonicViewModel? {
        guard let aezeed = aezeed else { return  nil }
        return ConfirmMnemonicViewModel(aezeed: aezeed)
    }
    
    func updatePageWords(with aezeed: [String]) {
        let maxWordCount = 6
        var subArrays = [[String]]()
        var array = aezeed
        
        while !array.isEmpty {
            let prefix = array.prefix(maxWordCount)
            subArrays.append(Array(prefix))
            array.removeFirst(maxWordCount)
        }
        
        var index = 0
        
        pageWords.value = subArrays.map {
            $0.map {
                defer { index += 1 }
                return MnemonicWord(index: index, word: $0)
            }
        }
    }
    
    init(walletUnlocker: WalletProtocol) {
        self.wallet = walletUnlocker
        
        walletUnlocker.generateSeed(passphrase: nil) { [weak self] result in
            guard let aezeed = result.value else { return }
            self?.aezeed = aezeed
        }
    }
}

struct MnemonicWord {
    let index: Int
    let word: String
}

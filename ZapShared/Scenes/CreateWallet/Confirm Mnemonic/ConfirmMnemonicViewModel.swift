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
    private let wallet: WalletProtocol
    private let mnemonic: [String]
    
    let wordList: [ConfirmWordViewModel]
    
    init(wallet: WalletProtocol, mnemonic: [String]) {
        self.wallet = wallet
        self.mnemonic = mnemonic
        
        var randomIndices = [Int]()
        while randomIndices.count < requiredWordCount {
            let randomNumber = Int(arc4random_uniform(UInt32(mnemonic.count)))
            if !randomIndices.contains(randomNumber) {
                randomIndices.append(randomNumber)
            }
        }
        randomIndices.sort()
        
        wordList = randomIndices.map { ConfirmWordViewModel(word: mnemonic[$0], index: $0) }
    }
    
    func didVerifyMnemonic() {
        wallet.initWallet(mnemonic: mnemonic, password: "12345678") { _ in } // TODO: store password somewhere save
    }
}

//
//  Zap
//
//  Created by Otto Suess on 09.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning

private let requiredWordCount = 6

struct ConfirmWordViewModel {
    let word: String
    let index: Int
}

final class ConfirmMnemonicViewModel {
    private let walletService: WalletService
    private let mnemonic: [String]
    
    let configuration: WalletConfiguration
    
    let wordList: [ConfirmWordViewModel]
    
    init(walletService: WalletService, mnemonic: [String], configuration: WalletConfiguration) {
        self.walletService = walletService
        self.mnemonic = mnemonic
        self.configuration = configuration
        
        var randomIndices = [Int]()
        while randomIndices.count < requiredWordCount {
            let randomNumber = Int.random(in: 0..<mnemonic.count)
            if !randomIndices.contains(randomNumber) {
                randomIndices.append(randomNumber)
            }
        }
        randomIndices.sort()
        
        wordList = randomIndices.map { ConfirmWordViewModel(word: mnemonic[$0], index: $0) }
    }
    
    func didVerifyMnemonic() {
        walletService.initWallet(mnemonic: mnemonic) { _ in }
    }
}

//
//  Zap
//
//  Created by Otto Suess on 09.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning
import SwiftLnd

private let requiredWordCount = 4

struct ConfirmWordViewModel: Equatable {
    let secretWord: MnemonicWord

    let context: [MnemonicWord]
    let answers: [MnemonicWord]
}

final class ConfirmMnemonicViewModel {
    private let walletService: WalletService
    private let mnemonic: [String]

    let wordViewModels: [ConfirmWordViewModel]

    init(walletService: WalletService, mnemonic: [String]) {
        self.walletService = walletService
        self.mnemonic = mnemonic

        var randomIndices = [Int]()
        while randomIndices.count < requiredWordCount {
            let randomNumber = Int.random(in: 1..<(mnemonic.count - 1))
            if !randomIndices.contains(randomNumber) {
                randomIndices.append(randomNumber)
            }
        }

        let mnemonicWords = mnemonic.enumerated().map { MnemonicWord(index: $0, word: $1) }

        wordViewModels = randomIndices.map {
            let secretWord = mnemonicWords[$0]

            var answers = Array(mnemonicWords.shuffled().prefix(4))
            if !answers.contains(secretWord) {
                answers.removeLast()
                answers.append(secretWord)
                answers.shuffle()
            }

            let contextStartIndex = min(max($0 - 1, 0), mnemonicWords.count - 3)
            let context = Array(mnemonicWords[contextStartIndex...contextStartIndex + 2])

            return ConfirmWordViewModel(secretWord: secretWord, context: context, answers: answers)
        }
    }

    func createWallet(completion: @escaping ApiCompletion<Success>) {
        walletService.initWallet(password: Password.create(), mnemonic: mnemonic, channelBackup: nil, recover: false, completion: completion)
    }
}

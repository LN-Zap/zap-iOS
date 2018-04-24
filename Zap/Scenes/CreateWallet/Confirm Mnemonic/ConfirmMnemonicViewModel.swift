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
    let viewModel: ViewModel
    let wordList: [ConfirmWordViewModel]
    
    init(aezeed: Aezeed, viewModel: ViewModel) {
        self.viewModel = viewModel
        
        var randomIndices = [Int]()
        while randomIndices.count < requiredWordCount {
            let randomNumber = Int(arc4random_uniform(UInt32(aezeed.wordList.count)))
            if !randomIndices.contains(randomNumber) {
                randomIndices.append(randomNumber)
            }
        }
        
        randomIndices.sort()
        
        wordList = randomIndices.map { ConfirmWordViewModel(word: aezeed.wordList[$0], index: $0) }
    }
    
    func didVerifyMnemonic() {
        ViewModel.didCreateWallet = true
    }
}

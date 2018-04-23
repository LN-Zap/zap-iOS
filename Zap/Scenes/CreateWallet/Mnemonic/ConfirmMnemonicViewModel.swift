//
//  Zap
//
//  Created by Otto Suess on 09.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

final class ConfirmMnemonicViewModel {
    let viewModel: ViewModel
    private let indices: [Int]
    private let aezeed: Aezeed
    private var currentIndex = 0
    
    let mnemonic = Observable<String?>(nil)
    let wordLabel = Observable<String>("")
    
    init(aezeed: Aezeed, viewModel: ViewModel) {
        self.aezeed = aezeed
        self.viewModel = viewModel
        
        var randomIndices = [Int]()
        while randomIndices.count < 3 {
            let randomNumber = Int(arc4random_uniform(UInt32(aezeed.wordList.count)))
            if !randomIndices.contains(randomNumber) {
                randomIndices.append(randomNumber)
            }
        }
        indices = randomIndices
        
        updateWord()
    }
    
    private func updateWord() {
        mnemonic.value = nil
        wordLabel.value = "Word #\(indices[currentIndex] + 1)"
    }
    
    private func didVerifyMnemonic() {
        ViewModel.didCreateWallet = true
    }
    
    func check() -> Bool {
        guard
            currentIndex < indices.count,
            mnemonic.value?.lowercased() == aezeed.wordList[indices[currentIndex]] || mnemonic.value == " " // TODO: REMOVE
            else { return false }

        currentIndex += 1
        
        if currentIndex < indices.count {
            updateWord()
            return false
        } else {
            didVerifyMnemonic()
            return true
        }
    }
}

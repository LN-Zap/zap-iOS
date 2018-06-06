//
//  Zap
//
//  Created by Otto Suess on 09.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

struct Aezeed {
    let wordList = ["print",
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
                      "budget"]
}

final class MnemonicViewModel {
    private let aezeed = Aezeed()
    private let viewModel: LightningService
    
    let wordList: Observable<[String]>
    
    var confirmMnemonicViewModel: ConfirmMnemonicViewModel {
        return ConfirmMnemonicViewModel(aezeed: aezeed, viewModel: viewModel)
    }
    
    var pageWords: [[MnemonicWord]] {
        let maxWordCount = 6
        var subArrays = [[String]]()
        var array = aezeed.wordList
        
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
    
    init(viewModel: LightningService) {
        self.viewModel = viewModel
        wordList = Observable<[String]>(aezeed.wordList)
    }
}

struct MnemonicWord {
    let index: Int
    let word: String
}

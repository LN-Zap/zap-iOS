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
    private let viewModel: ViewModel
    
    let wordList: Observable<[String]>
    
    var confirmMnemonicViewModel: ConfirmMnemonicViewModel {
        return ConfirmMnemonicViewModel(aezeed: aezeed, viewModel: viewModel)
    }
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        wordList = Observable<[String]>(aezeed.wordList)
    }
}

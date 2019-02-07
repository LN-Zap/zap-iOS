//
//  ZapShared
//
//  Created by Otto Suess on 20.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Lightning
import SwiftBTC
import SwiftLnd

final class RecoverWalletViewModel {
    let configuration: WalletConfiguration
    
    init(configuration: WalletConfiguration) {
        self.configuration = configuration
    }
    
    private func mnemonic(from text: String) -> [String] {
        let characters = CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: ","))
        return text.components(separatedBy: characters).filter { $0 != "" }
    }
    
    func recoverWallet(with text: String, completion: @escaping (Result<Success, LndApiError>) -> Void) {
        let mnemonic = self.mnemonic(from: text.lowercased())
        
        let walletService = WalletService(connection: configuration.connection)
        walletService.initWallet(mnemonic: mnemonic, completion: completion)
    }
    
    func attributedString(from text: String) -> NSAttributedString {
        let mnemonic = self.mnemonic(from: text)
        
        let attributestText = NSMutableAttributedString(string: text, attributes: [
            .foregroundColor: UIColor.white,
            .font: UIFont.Zap.light
        ])
        
        // TODO: highlight correct range
        for word in mnemonic {
            guard
                !Bip39.contains(word.lowercased()),
                let wordRange = text.range(of: word)
                else { continue }
            let range = NSRange(wordRange, in: text)
            attributestText.addAttributes([.foregroundColor: UIColor.Zap.superRed], range: range)
        }
        
        return attributestText
    }
}

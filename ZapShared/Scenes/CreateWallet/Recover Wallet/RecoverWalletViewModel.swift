//
//  ZapShared
//
//  Created by Otto Suess on 20.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

final class RecoverWalletViewModel {
    let wallet: WalletProtocol
    let bip39Words: [String]
    
    init(wallet: WalletProtocol) {
        self.wallet = wallet
        
        guard
            let path = Bundle.zap.path(forResource: "bip39", ofType: "txt"),
            let bip39String = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)
            else { fatalError("bip39 file missing") }
        bip39Words = bip39String.components(separatedBy: .whitespacesAndNewlines).filter { $0 != "" }
    }
    
    private func mnemonic(from text: String) -> [String] {
        let characters = CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: ","))
        return text.components(separatedBy: characters).filter { $0 != "" }
    }
    
    func recoverWallet(with text: String, callback: @escaping (Result<Void>) -> Void) {
        let mnemonic = self.mnemonic(from: text.lowercased())
        wallet.initWallet(mnemonic: mnemonic, password: "12345678") {
            callback($0)
            WalletService.didCreateWallet = true
        }
    }
    
    func attributedString(from text: String) -> NSAttributedString {
        let mnemonic = self.mnemonic(from: text)
        
        let attributestText = NSMutableAttributedString(string: text, attributes: [
            .foregroundColor: UIColor.white,
            .font: UIFont.zap.light
        ])
        
        // TODO: highlight correct range
        for word in mnemonic {
            guard
                !bip39Words.contains(word.lowercased()),
                let wordRange = text.range(of: word)
                else { continue }
            let range = NSRange(wordRange, in: text)
            attributestText.addAttributes([.foregroundColor: UIColor.zap.tomato], range: range)
        }
        
        return attributestText
    }
}

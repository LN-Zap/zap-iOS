//
//  ZapShared
//
//  Created by Otto Suess on 20.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning
import SwiftBTC
import SwiftLnd

final class RecoverWalletViewModel {
    let connection: LightningConnection

    var staticChannelBackup: ChannelBackup?

    init(connection: LightningConnection) {
        self.connection = connection
    }

    let mnemonic = Observable([String]())
    static let separatorCharacterSet = CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: ".,"))

    private func mnemonic(from text: String) -> [String] {
        return text.components(separatedBy: RecoverWalletViewModel.separatorCharacterSet).filter { $0 != "" }
    }

    func recoverWallet(with text: String, completion: @escaping ApiCompletion<Success>) {
        let mnemonic = self.mnemonic(from: text.lowercased())

        let walletService = WalletService(connection: connection)
        walletService.initWallet(password: Password.create(), mnemonic: mnemonic, channelBackup: staticChannelBackup, completion: completion)
    }

    func attributedString(from text: String) -> NSAttributedString {
        let mnemonic = self.mnemonic(from: text)
        self.mnemonic.value = mnemonic

        var newText = mnemonic.joined(separator: " ")
        if text.suffix(1).trimmingCharacters(in: RecoverWalletViewModel.separatorCharacterSet).isEmpty {
            newText += " "
        }

        let attributestText = NSMutableAttributedString(string: newText, attributes: [
            .foregroundColor: UIColor.white,
            .font: UIFont.Zap.light
        ])

        for (index, word) in mnemonic.enumerated() {
            guard !Bip39.contains(word.lowercased()) else { continue }

            let location = mnemonic[0..<index].reduce(0) { $0 + $1.count } + index
            let range = NSRange(location: location, length: word.count)
            attributestText.addAttributes([.foregroundColor: UIColor.Zap.superRed], range: range)
        }

        return attributestText
    }
}

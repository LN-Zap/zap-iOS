//
//  Zap
//
//  Created by Otto Suess on 23.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class ConfirmMnemonicCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var bottomLineView: UIView!

    var wordConfirmedCallback: (() -> Void)?

    var confirmWordViewModel: ConfirmWordViewModel? {
        didSet {
            guard let confirmWordViewModel = confirmWordViewModel else { return }
            textField?.attributedPlaceholder = NSAttributedString(
                string: "#\(confirmWordViewModel.index + 1)",
                attributes: [.foregroundColor: UIColor.gray]
            )
        }
    }

    var isActiveCell: Bool = false {
        didSet {
            if isActiveCell {
                textField.becomeFirstResponder()
                bottomLineView.backgroundColor = .white
            } else {
                textField.resignFirstResponder()
                bottomLineView.backgroundColor = .gray
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear

        bottomLineView.backgroundColor = .gray

        textField?.delegate = self

        if let textField = textField {
            Style.textField(color: .white).apply(to: textField)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        bottomLineView.backgroundColor = .gray
    }

    @IBAction private func textFieldEdidtingChanged(_ sender: UITextField) {
        if sender.text == confirmWordViewModel?.word ||
            (Environment.allowFakeMnemonicConfirmation && sender.text == "xx") {
            wordConfirmedCallback?()
        } else {
            bottomLineView.backgroundColor = UIColor.Zap.superRed
        }
    }
}

extension ConfirmMnemonicCollectionViewCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return isActiveCell
    }
}

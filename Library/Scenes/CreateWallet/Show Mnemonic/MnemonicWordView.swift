//
//  Library
//
//  Created by 0 on 15.07.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

final class MnemonicWordView: UIView {
    init(mnemonic: MnemonicWord) {
        super.init(frame: CGRect.zero)

        let indexLabel = UILabel(frame: CGRect.zero)
        if mnemonic.index < 9 {
            indexLabel.text = "0\(mnemonic.index + 1)"
        } else {
            indexLabel.text = "\(mnemonic.index + 1)"
        }

        let wordLabel = UILabel(frame: CGRect.zero)
        wordLabel.text = "\(mnemonic.word)"
        Style.Label.body.apply(to: wordLabel)
        indexLabel.textColor = UIColor.Zap.gray
        indexLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .light)

        indexLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 999), for: .horizontal)

        let horizontalStackView = UIStackView(arrangedSubviews: [
            indexLabel,
            wordLabel
        ])

        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 20

        if mnemonic.index % 2 == 0 {
            backgroundColor = UIColor.Zap.seaBlue
        }

        addAutolayoutSubview(horizontalStackView)

        NSLayoutConstraint.activate([
            horizontalStackView.topAnchor.constraint(equalTo: self.topAnchor),
            horizontalStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            horizontalStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            horizontalStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 20)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

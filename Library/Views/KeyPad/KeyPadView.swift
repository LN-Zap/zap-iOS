//
//  Zap
//
//  Created by Otto Suess on 25.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

enum KeyPadState {
    case authenticate
    case setupPin
    case amountInput
}

final class KeyPadView: UIView {
    @IBOutlet private var contentView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        Bundle.library.loadNibNamed("KeyPadView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        updateButtonFont()
    }

    override var backgroundColor: UIColor? {
        didSet {
            contentView.backgroundColor = backgroundColor
        }
    }
    
    //////
    
    var handler: ((String) -> Bool)?
    var customPointButtonAction: (() -> Void)?
    
    var state: KeyPadState = .amountInput {
        didSet {
            updatePointButton()
        }
    }
    var textColor = UIColor.Zap.black {
        didSet {
            updateButtonFont()
        }
    }
    
    @IBOutlet private var buttons: [UIButton]?
    @IBOutlet private weak var pointButton: UIButton! {
        didSet {
            updatePointButton()
        }
    }
    
    var numberString = "" {
        didSet {
            guard oldValue != numberString else { return }
            print(numberString)
        }
    }
    
    private var pointCharacter: String {
        return Locale.autoupdatingCurrent.decimalSeparator ?? "."
    }
    
    private var authenticationImage: UIImage? {
        let imageName: String
        switch BiometricAuthentication.type {
        case .none:
            return nil
        case .touchID:
            imageName = "icon_touch_id"
        case .faceID:
            imageName = "icon_face_id"
        }
        return UIImage(named: imageName, in: Bundle.library, compatibleWith: nil)
    }
    
    private func updateButtonFont() {
        buttons?.forEach {
            Style.Button.custom().apply(to: $0)
            $0.setTitleColor(textColor, for: .normal)
            $0.imageView?.tintColor = textColor
            $0.titleLabel?.font = $0.titleLabel?.font.withSize(24)
        }
    }
    
    private func updatePointButton() {
        switch state {
        case .authenticate:
            pointButton.setImage(authenticationImage, for: .normal)
            pointButton.imageView?.tintColor = textColor
            pointButton.setTitle(nil, for: .normal)
            pointButton.isEnabled = true
        case .setupPin:
            pointButton.setImage(nil, for: .normal)
            pointButton.setTitle(nil, for: .normal)
            pointButton.isEnabled = false
        case .amountInput:
            pointButton.setImage(nil, for: .normal)
            pointButton.setTitle(pointCharacter, for: .normal)
            pointButton.isEnabled = true
        }
    }
    
    private func numberTapped(_ number: Int) {
        if numberString == "0" && state == .amountInput {
            proposeNumberString(String(describing: number))
        } else {
            proposeNumberString(numberString + String(describing: number))
        }
    }
    
    private func pointTapped() {
        if let customPointButtonAction = customPointButtonAction {
            customPointButtonAction()
        } else {
            proposeNumberString(numberString + pointCharacter)
        }
    }
    
    private func backspaceTapped() {
        proposeNumberString(String(numberString.dropLast()))
    }
    
    @IBAction private func buttonTapped(_ sender: UIButton) {
        if sender.tag < 10 {
            numberTapped(sender.tag)
        } else if sender.tag == 10 {
            pointTapped()
        } else {
            backspaceTapped()
        }
    }
    
    private var deleteTimer: Timer?
    
    @IBAction private func longPressChanged(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
                self?.backspaceTapped()
            }
            deleteTimer?.fire()
        case .ended:
            deleteTimer?.invalidate()
        default:
            break
        }
    }
    
    private func proposeNumberString(_ string: String) {
        guard string != numberString else { return }
        
        if let handler = handler {
            if handler(string) {
                numberString = string
            }
        } else {
            numberString = string
        }
    }
}

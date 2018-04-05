//
//  Zap
//
//  Created by Otto Suess on 26.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

class NumericKeyPadViewController: UIViewController {
    var handler: ((String) -> Bool)?

    var isPin = false {
        didSet {
            pointButton?.isEnabled = !isPin
        }
    }
    var textColor = Color.text {
        didSet {
            updateButtonFont()
        }
    }
    
    @IBOutlet private var buttons: [UIButton]?
    @IBOutlet private weak var pointButton: UIButton! {
        didSet {
            let decimalSeparator = Locale.current.decimalSeparator ?? "."
            pointButton.setTitle(decimalSeparator, for: .normal)
            pointButton?.isEnabled = !isPin
        }
    }
    
    private var numberString = "" {
        didSet {
            guard oldValue != numberString else { return }
            print(numberString)
        }
    }
    
    private var pointCharacter: String {
        return NumberFormatter().decimalSeparator
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateButtonFont()
    }
    
    private func updateButtonFont() {
        buttons?.forEach {
            Style.button.apply(to: $0)
            $0.setTitleColor(textColor, for: .normal)
            $0.imageView?.tintColor = Color.text
            $0.titleLabel?.font = $0.titleLabel?.font.withSize(24)
        }
    }
 
    private func numberTapped(_ number: Int) {
        if numberString == "0" {
            proposeNumberString(String(describing: number))
        } else {
            proposeNumberString(numberString + String(describing: number))
        }
    }
    
    private func pointTapped() {
        proposeNumberString(numberString + pointCharacter)
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

//
//  Library
//
//  Created by Otto Suess on 27.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

protocol KeyPadPinViewDelegate: class {
    func startBiometricAuthentication()
    func didAuthenticate()
}

final class KeyPadPinView: KeyPadView {
    weak var delegate: KeyPadPinViewDelegate?

    var authenticationViewModel: AuthenticationViewModel? {
        didSet { updatePinView() }
    }

    var pinView: PinView? {
        didSet { updatePinView() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func updatePinView() {
        pinView?.characterCount = PinStore.pinCount ?? 0
    }

    private func setup() {
        state = .pinBiometric

        customPointButtonAction = { [weak self] in
            self?.delegate?.startBiometricAuthentication()
        }

        handler = { [weak self] number in
            self?.updatePinView(for: number)
            self?.checkPin(string: number)

            return (PinStore.pinCount ?? Int.max) > number.count
        }
    }

    private func updatePinView(for string: String) {
        pinView?.activeCount = string.count
    }

    private func checkPin(string: String) {
        guard
            let authenticationViewModel = authenticationViewModel,
            string.count == PinStore.pinCount
            else { return }

        switch authenticationViewModel.authenticate(string) {
        case .success:
            delegate?.didAuthenticate()
        case .failure:
            isUserInteractionEnabled = false
            pinView?.startShakeAnimation {
                self.isUserInteractionEnabled = true
                self.numberString = ""
                self.updatePinView(for: "")
            }
        }
    }
}

//
//  Zap
//
//  Created by Otto Suess on 23.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

enum SetupPinState {
    case reset
    case completed
}

final class SetupPinViewModel {
    
    let pinAtiveCount = Observable(0)
    let pinCharacterCount = Observable(0)
    let doneButtonEnabled = Observable(false)
    let topLabelText: Observable<String>
    let state = Observable<SetupPinState?>(nil)
    private var firstPin: String?
    private var currentPin: String?
    
    init() {
        topLabelText = Observable("Choose a pin.")
    }
    
    func updateCurrentPin(_ pin: String) -> Bool {
        guard pin.count <= firstPin?.count ?? 12 else { return false }
        
        doneButtonEnabled.value = pin.count >= 4 && firstPin == nil
        
        currentPin = pin
        if firstPin == nil {
            pinCharacterCount.value = pin.count
        } else {
            pinAtiveCount.value = pin.count
        }
        
        if pin.count == firstPin?.count {
            if pin == firstPin {
                AuthenticationViewModel.shared.pin = pin
                AuthenticationViewModel.shared.authenticated.value = true

                state.value = .completed                
            } else {
                firstPin = nil
                currentPin = nil
                pinCharacterCount.value = 0
                pinAtiveCount.value = 0
                topLabelText.value = "The pins didn't match. Please try again."
                state.value = .reset
                return false
            }
        }
        
        return true
    }
    
    func doneButtonTapped() {
        firstPin = currentPin
        doneButtonEnabled.value = false
        topLabelText.value = "Enter the pin again to validate."
    }
}

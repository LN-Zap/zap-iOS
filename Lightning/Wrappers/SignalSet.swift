//
//  SwiftLnd
//
//  Created by Christopher Pinski on 10/12/19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import ReactiveKit

public class SignalSet<T, E: Error> {
    
    public let signal: Signal<T, E>
    public let observer: AnyObserver<T, E>
    
    public init() {
        let (signal, observer) = Signal<T, E>.withObserver()
        self.signal = signal
        self.observer = observer
    }
}

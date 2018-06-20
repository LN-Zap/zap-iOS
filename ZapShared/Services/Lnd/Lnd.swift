//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation
import Lndmobile

public final class Lnd {
    public private(set) static var isRunning: Bool = false
    
    public struct Constants {
        static let minChannelSize: Satoshi = 20000
        static let maxChannelSize: Satoshi = 16777216
        public static let maxPaymentAllowed: Satoshi = 4294967
    }
    
    static var path: URL {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            else { fatalError("lnd path not found") }
        return url
    }
    
    static func start() {
        isRunning = true
        LndConfiguration.standard.save(at: path)

        guard !Environment.isRunningTests else { return }
        DispatchQueue.global(qos: .userInteractive).async {
            LndmobileStart(Lnd.path.path, EmptyStreamCallback())
        }
    }
    
    static func stop() {
        isRunning = false
        LndmobileStopDaemon(nil, EmptyStreamCallback())
    }
}

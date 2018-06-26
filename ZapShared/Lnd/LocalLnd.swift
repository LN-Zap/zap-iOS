//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import Lndmobile

public final class LocalLnd {
    public private(set) static var isRunning: Bool = false
    
    static var path: URL {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            else { fatalError("lnd path not found") }
        return url
    }
    
    static func start() {
        isRunning = true
        LocalLndConfiguration.standard.save(at: path)

        guard !Environment.isRunningTests else { return }
        DispatchQueue.global(qos: .userInteractive).async {
            LndmobileStart(LocalLnd.path.path, EmptyStreamCallback())
        }
    }
    
    static func stop() {
        isRunning = false
        LndmobileStopDaemon(nil, EmptyStreamCallback())
    }
}

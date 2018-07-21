//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

#if !LOCALONLY

import Foundation
import Lndmobile

// TODO: should be private
public final class LocalLnd {
    public private(set) static var isRunning = false
    
    static var path: URL {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            else { fatalError("lnd path not found") }
        return url
    }
    
    public static func start() {
        isRunning = true
        LocalLndConfiguration.standard.save(at: path)

        guard !Environment.isRunningTests else { return }
        DispatchQueue.global(qos: .userInteractive).async {
            LndmobileStart(LocalLnd.path.path, EmptyStreamCallback())
        }
    }
    
    public static func stop() {
        isRunning = false
        LndmobileStopDaemon(nil, EmptyStreamCallback())
    }
}

#else

public final class LocalLnd {
    public static let isRunning = false
    public static func start() {}
    public static func stop() {}
}

#endif

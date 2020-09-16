//
//  Zap
//
//  Created by Manu Herrera on 16/09/2020.
//  Copyright © 2020 Zap. All rights reserved.
//

import Network

enum NetworkConnection {

    static func startConnectivityCheck(status: @escaping (Bool) -> Void) {

        if #available(iOS 12.0, *) {
            let monitor = NWPathMonitor()
            monitor.pathUpdateHandler = { path in
                let isConnected = (path.status == .satisfied)
                status(isConnected)
            }

            let queue = DispatchQueue(label: "Monitor")
            monitor.start(queue: queue)
        } else {
            // TODO: Check connection status for iOS versions < 12
            // Just return status connected for the time being
            status(true)
        }
    }
}

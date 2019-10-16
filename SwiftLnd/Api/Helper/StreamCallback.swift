//
//  Zap
//
//  Created by Otto Suess on 03.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

#if !REMOTEONLY

import Foundation
import Lndmobile
import Logger

final class EmptyStreamCallback: NSObject, LndmobileCallbackProtocol {
    func onError(_ error: Error?) {
        guard let error = error else { return }
        Logger.error("EmptyCallback Error: \(error.localizedDescription)")
    }

    func onResponse(_ data: Data?) {
        guard let data = data else { return }
        Logger.info("EmptyCallback: \(data), '\(String(data: data, encoding: .utf8) ?? "-")'", customPrefix: "🍕")
    }
}
#endif

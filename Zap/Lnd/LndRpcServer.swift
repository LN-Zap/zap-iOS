//
//  Zap
//
//  Created by Otto Suess on 22.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

final class LndRpcServer {
    let service: Lnrpc_LightningService
    
    init(configuration: RemoteNodeConfiguration) {
        service = Lnrpc_LightningServiceClient(address: configuration.url.absoluteString, certificates: configuration.remoteNodeCertificates.certificate, host: nil)
        service.metadata.add(key: "macaroon", value: configuration.remoteNodeCertificates.macaron.hexString())
    }
    
    func canConnect(callback: @escaping (Bool) -> Void) {
        do {
            _ = try service.getInfo(Lnrpc_GetInfoRequest()) { response, _ in
                callback(response != nil)
            }
        } catch {
            callback(false)
        }
    }
}

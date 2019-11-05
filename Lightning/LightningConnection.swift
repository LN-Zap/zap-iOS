//
//  Zap
//
//  Created by Otto Suess on 22.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftLnd

public enum LightningConnection: Equatable, Codable {
    case local
    case remote(RPCCredentials)

    public var api: LightningApi? {
        if Environment.useUITestMockApi {
            return LightningApi(connection: .mock(.screenshots))
        } else if Environment.useMockApi {
            return LightningApi(connection: .mock(.selected))
        }

        switch self {
        case .local:
        #if !REMOTEONLY
            return LightningApi(connection: .stream)
        #else
            return nil
        #endif
        case .remote(let configuration):
            return LightningApi(connection: .grpc(configuration))
        }
    }
}

// MARK: Codable
extension LightningConnection {
    private enum CodingKeys: String, CodingKey {
        case base, remoteRpcConfiguration
    }

    private enum Base: String, Codable {
        case local
        case remote
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base = try container.decode(Base.self, forKey: .base)

        switch base {
        case .local:
            self = .local
        case .remote:
            let rpcCredentials = try container.decode(RPCCredentials.self, forKey: .remoteRpcConfiguration)
            self = .remote(rpcCredentials)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .local:
            try container.encode(Base.local, forKey: .base)
        case .remote(let rpcCredentials):
            try container.encode(Base.remote, forKey: .base)
            try container.encode(rpcCredentials, forKey: .remoteRpcConfiguration)
        }
    }
}

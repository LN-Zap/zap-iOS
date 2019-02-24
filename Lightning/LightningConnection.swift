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
    case remote(RemoteRPCConfiguration)

    public var api: LightningApiProtocol {
        if Environment.useMockApi {
            return ApiMockTemplate.selected.instance
        }

        switch self {
        case .local:
        #if !REMOTEONLY
            return LightningApiStream()
        #else
            fatalError(".local not supported")
        #endif
        case .remote(let configuration):
            return LightningApiRpc(configuration: configuration)
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
            let remoteRpcConfiguration = try container.decode(RemoteRPCConfiguration.self, forKey: .remoteRpcConfiguration)
            self = .remote(remoteRpcConfiguration)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .local:
            try container.encode(Base.local, forKey: .base)
        case .remote(let remoteRPCConfiguration):
            try container.encode(Base.remote, forKey: .base)
            try container.encode(remoteRPCConfiguration, forKey: .remoteRpcConfiguration)
        }
    }
}

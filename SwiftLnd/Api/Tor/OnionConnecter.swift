//
//  SwiftLnd
//
//  Created by 0 on 08.10.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Logger

public final class OnionConnecter {
    public enum OnionError: Error {
        case connectionError
    }

    private static var urlSessionConfiguration: URLSessionConfiguration?
    
    private var progress: ((Int) -> Void)?
    private var completion: ((Result<URLSessionConfiguration, OnionError>) -> Void)?

    public init() {}

    public func start(progress: ((Int) -> Void)?, completion: @escaping (Result<URLSessionConfiguration, OnionError>) -> Void) {
        if let urlSessionConfiguration = OnionConnecter.urlSessionConfiguration {
            completion(.success(urlSessionConfiguration))
        } else {
            self.progress = progress
            self.completion = completion
            OnionManager.shared.startTor(delegate: self)
        }
    }
}

extension OnionConnecter: OnionManagerDelegate {
    func torConnProgress(_ progress: Int) {
        Logger.info("\(progress)")
        self.progress?(progress)
    }

    func torConnFinished(configuration: URLSessionConfiguration) {
        // TODO: this is a fix for Tor 400.5.2. Can be removed once there is a
        // new release on github.
        configuration.connectionProxyDictionary = [
            kCFProxyTypeKey: kCFProxyTypeSOCKS,
            kCFStreamPropertySOCKSProxyHost: "localhost",
            kCFStreamPropertySOCKSProxyPort: 39050
        ]
        if #available(iOSApplicationExtension 13.0, *) {
            configuration.tlsMaximumSupportedProtocolVersion = .TLSv12
        } else {
            configuration.tlsMinimumSupportedProtocol = .tlsProtocol12
        }
        
        OnionConnecter.urlSessionConfiguration = configuration
        
        completion?(.success(configuration))
    }

    func torConnError() {
        Logger.error("torConnError")
        completion?(.failure(.connectionError))
    }
}

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

    private var progress: ((Int) -> Void)?
    private var completion: ((Result<URLSessionConfiguration, OnionError>) -> Void)?

    public init() {}

    public func start(progress: @escaping (Int) -> Void, completion: @escaping (Result<URLSessionConfiguration, OnionError>) -> Void) {
        self.progress = progress
        self.completion = completion
        OnionManager.shared.startTor(delegate: self)
    }
}

extension OnionConnecter: OnionManagerDelegate {
    func torConnProgress(_ progress: Int) {
        Logger.info("\(progress)")
        self.progress?(progress)
    }

    func torConnFinished(configuration: URLSessionConfiguration) {
        completion?(.success(configuration))
    }

    func torConnError() {
        Logger.error("torConnError")
        completion?(.failure(.connectionError))
    }
}

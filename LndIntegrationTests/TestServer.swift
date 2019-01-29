//
//  LndIntegrationTests
//
//  Created by Otto Suess on 25.01.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
@testable import SwiftLnd

private final class TestBundleToken {}

enum TestServer: String {
    case start
    case stop
    
    static var rpcConfiguration: RemoteRPCConfiguration {
        let bundle = Bundle(for: TestBundleToken.self)
        guard
            let macaroonUrl = bundle.url(forResource: "admin", withExtension: "macaroon"),
            let macaroonData = try? Data(contentsOf: macaroonUrl),
        
            let certificatePath = bundle.path(forResource: "tls", ofType: "cert"),
            let certificateString = try? String(contentsOfFile: certificatePath),
        
            let serverUrl = URL(string: "localhost:10001")
        
            else { fatalError("Error: admin.macaroon not found.") }
    
        let macaroon = Macaroon(data: macaroonData)
        
        return RemoteRPCConfiguration(certificate: certificateString, macaroon: macaroon, url: serverUrl)
    }
    
    @discardableResult func run() -> Bool {
        print("📡 \(rawValue)")
        
        let request = URLRequest(url: URL(string: "http://127.0.0.1:8080/\(rawValue)")!) // swiftlint:disable:this force_unwrapping
        
        var success = false
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print(error)
            } else if let response = response as? HTTPURLResponse,
                300..<600 ~= response.statusCode {
                print("Error, statusCode: \(response.statusCode)")
            } else {
                success = true
            }
            semaphore.signal()
        }
        
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return success
    }
}

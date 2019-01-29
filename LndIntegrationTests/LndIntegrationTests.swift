//
//  LndIntegrationTests
//
//  Created by Otto Suess on 25.01.19.
//  Copyright © 2019 Zap. All rights reserved.
//

@testable import Lightning
import XCTest

class LndIntegrationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        TestServer.start.run()
    }
    
    override func tearDown() {
        TestServer.stop.run()
        
        super.tearDown()
    }
    
    func testSetup() {
        let service = LightningService(connection: LightningConnection.remote(TestServer.rpcConfiguration))
        
        XCTAssertNotNil(service)
        sleep(2)
        print(service!.infoService.info)
    }
}

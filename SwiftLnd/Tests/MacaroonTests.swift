//
//  SwiftLndTests
//
//  Created by Otto Suess on 23.11.18.
//  Copyright © 2018 Zap. All rights reserved.
//

@testable import SwiftLnd
import XCTest

class MacaroonTests: XCTestCase {
    let admin = "AgEDbG5kArsBAwoQ3/I9f6kgSE6aUPd85lWpOBIBMBoWCgdhZGRyZXNzEgRyZWFkEgV3cml0ZRoTCgRpbmZvEgRyZWFkEgV3cml0ZRoXCghpbnZvaWNlcxIEcmVhZBIFd3JpdGUaFgoHbWVzc2FnZRIEcmVhZBIFd3JpdGUaFwoIb2ZmY2hhaW4SBHJlYWQSBXdyaXRlGhYKB29uY2hhaW4SBHJlYWQSBXdyaXRlGhQKBXBlZXJzEgRyZWFkEgV3cml0ZQAABiAiUTBv3Eh6iDbdjmXCfNxp4HBEcOYNzXhrm+ncLHf5jA=="
    let invoice = "AgEDbG5kAkcDChDd8j1/qSBITppQ93zmVak4EgEwGhYKB2FkZHJlc3MSBHJlYWQSBXdyaXRlGhcKCGludm9pY2VzEgRyZWFkEgV3cml0ZQAABiBgkAkYoKwggY3r4JUiYgxuuKqx83Q5NVfZrAlmCqWSjQ=="
    let readonly = "AgEDbG5kAooBAwoQ3vI9f6kgSE6aUPd85lWpOBIBMBoPCgdhZGRyZXNzEgRyZWFkGgwKBGluZm8SBHJlYWQaEAoIaW52b2ljZXMSBHJlYWQaDwoHbWVzc2FnZRIEcmVhZBoQCghvZmZjaGFpbhIEcmVhZBoPCgdvbmNoYWluEgRyZWFkGg0KBXBlZXJzEgRyZWFkAAAGIAjs+7H6qNkFkm+nr51NGO5SYwUW9465Gn2T/U8NBDdC"
    
    // swiftlint:disable force_unwrapping
    func testAdminMacaroon() {
        let macaroon = Macaroon(base64String: admin)!
        XCTAssertTrue(macaroon.permissions.can(.write, domain: .address))
    }
    
    func testReadonlyMacaroon() {
        let macaroon = Macaroon(base64String: readonly)!
        XCTAssertFalse(macaroon.permissions.can(.write, domain: .address))
    }
    
    func testInvoiceMacaroon() {
        let macaroon = Macaroon(base64String: invoice)!
        XCTAssertTrue(macaroon.permissions.can(.write, domain: .invoices))
        XCTAssertTrue(macaroon.permissions.can(.write, domain: .address))
        XCTAssertFalse(macaroon.permissions.can(.write, domain: .onChain))
        XCTAssertFalse(macaroon.permissions.can(.read, domain: .info))
        
    }
}

//
//  LightningTests
//
//  Created by 0 on 02.04.19.
//  Copyright © 2019 Zap. All rights reserved.
//

@testable import SwiftLnd
import XCTest

// swiftlint:disable force_unwrapping
class VersionTests: XCTestCase {

    func testVersionNumber() {
        let versionNumber = Version.Number(string: "0.5.1-beta")
        XCTAssertNotNil(versionNumber)
        XCTAssertEqual(versionNumber?.string, "0.5.1")
    }

    func testEqualVersionNumber() {
        XCTAssertTrue(Version.Number(string: "0.5.1-beta")! == Version.Number(string: "0.5.1-asd commit=asd")!)
        XCTAssertTrue(Version.Number(string: "1")! == Version.Number(string: "1.0")!)
        XCTAssertTrue(Version.Number(string: "1.0")! == Version.Number(string: "1")!)
        XCTAssertTrue(Version.Number(string: "0.5.1")! != Version.Number(string: "2")!)
    }

    func testSmallerVersionNumber() {
        XCTAssertTrue(Version.Number(string: "0.5.0-beta")! < Version.Number(string: "0.5.1-asd commit=asd")!)
        XCTAssertTrue(Version.Number(string: "0")! < Version.Number(string: "0.5.1")!)
        XCTAssertTrue(Version.Number(string: "0.5")! < Version.Number(string: "0.5.1")!)
        XCTAssertTrue(Version.Number(string: "0.5.1")! < Version.Number(string: "2")!)
        XCTAssertTrue(Version.Number(string: "0.5.1")! < Version.Number(string: "10.0.0.0")!)
        XCTAssertTrue(Version.Number(string: "0.5.1")! < Version.Number(string: "10.10.10.10")!)
    }

    func testGreaterVersionNumber() {
        XCTAssertTrue(Version.Number(string: "0.5.3-beta")! > Version.Number(string: "0.5.1-asd commit=asd")!)
        XCTAssertTrue(Version.Number(string: "1")! > Version.Number(string: "0.5.1")!)
        XCTAssertTrue(Version.Number(string: "0.5.2")! > Version.Number(string: "0.5.1")!)
        XCTAssertTrue(Version.Number(string: "2.5.1")! > Version.Number(string: "2")!)
        XCTAssertTrue(Version.Number(string: "10.5.1")! > Version.Number(string: "10.0.0.0")!)
        XCTAssertTrue(Version.Number(string: "10.10.10.10")! > Version.Number(string: "0.5.1")!)
    }

    func testVersion() {
        let version = Version(string: "0.5.1-beta commit=v0.5.1-beta-161-g8de7564645217c84c44d77106d56cdb126653bf8")
        XCTAssertEqual(version?.number.string, "0.5.1")
        XCTAssertEqual(version?.commit, "g8de7564645217c84c44d77106d56cdb126653bf8")
    }
}

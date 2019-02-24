//
//  LibraryTests
//
//  Created by Otto Suess on 11.10.18.
//  Copyright © 2018 Zap. All rights reserved.
//

@testable import Library
@testable import Lightning
import ScrollableGraphView
import SwiftBTC
import XCTest

final class GraphViewDataSourceTests: XCTestCase {
    let plot = DotPlot(identifier: "dots")
    let currency = Bitcoin.satoshi

    struct MockPlottableEvent: PlottableEvent {
        let amount: Satoshi
        let date: Date
    }

    func testZeroBalance() {
        let dataSource = GraphViewDataSource(currentValue: 0, plottableEvents: [], currency: currency)

        XCTAssertEqual(dataSource.numberOfPoints(), 1)
        XCTAssertEqual(dataSource.value(forPlot: plot, atIndex: 0), 0)
    }

    func testSingleEvent() {
        let plottableEvents: [MockPlottableEvent] = []
        let dataSource = GraphViewDataSource(currentValue: 1000, plottableEvents: plottableEvents, currency: currency)

        XCTAssertEqual(dataSource.numberOfPoints(), 2)
        XCTAssertEqual(dataSource.value(forPlot: plot, atIndex: 0), 0)
        XCTAssertEqual(dataSource.value(forPlot: plot, atIndex: 1), 1000)
    }

    func testOneEventToday() {
        let plottableEvents: [MockPlottableEvent] = [
            MockPlottableEvent(amount: -500, date: Date())
        ]
        let dataSource = GraphViewDataSource(currentValue: 1000, plottableEvents: plottableEvents, currency: currency)

        XCTAssertEqual(dataSource.numberOfPoints(), 3)
        XCTAssertEqual(dataSource.value(forPlot: plot, atIndex: 0), 0)
        XCTAssertEqual(dataSource.value(forPlot: plot, atIndex: 1), 1500)
        XCTAssertEqual(dataSource.value(forPlot: plot, atIndex: 2), 1000)
    }

    func testOneEventYesterday() {
        let plottableEvents: [MockPlottableEvent] = [
            MockPlottableEvent(amount: -500, date: Date().add(day: -1))
        ]
        let dataSource = GraphViewDataSource(currentValue: 1000, plottableEvents: plottableEvents, currency: currency)

        XCTAssertEqual(dataSource.numberOfPoints(), 4)
        XCTAssertEqual(dataSource.value(forPlot: plot, atIndex: 0), 0)
        XCTAssertEqual(dataSource.value(forPlot: plot, atIndex: 1), 1500)
        XCTAssertEqual(dataSource.value(forPlot: plot, atIndex: 2), 1000)
        XCTAssertEqual(dataSource.value(forPlot: plot, atIndex: 3), 1000)
    }

    func testMultipleEvents() {
        let plottableEvents: [MockPlottableEvent] = [
            MockPlottableEvent(amount: -10, date: Date().add(day: -4)),
            MockPlottableEvent(amount: -50, date: Date().add(day: -2)),
            MockPlottableEvent(amount: 100, date: Date().add(day: -1)),
            MockPlottableEvent(amount: -500, date: Date())
        ]
        let dataSource = GraphViewDataSource(currentValue: 1000, plottableEvents: plottableEvents, currency: currency)

        XCTAssertEqual(dataSource.numberOfPoints(), 7)
        XCTAssertEqual(dataSource.value(forPlot: plot, atIndex: 0), 0)
        XCTAssertEqual(dataSource.value(forPlot: plot, atIndex: 1), 1460)
        XCTAssertEqual(dataSource.value(forPlot: plot, atIndex: 2), 1450)
        XCTAssertEqual(dataSource.value(forPlot: plot, atIndex: 3), 1450)
        XCTAssertEqual(dataSource.value(forPlot: plot, atIndex: 4), 1400)
        XCTAssertEqual(dataSource.value(forPlot: plot, atIndex: 5), 1500)
        XCTAssertEqual(dataSource.value(forPlot: plot, atIndex: 6), 1000)
    }

    func testNegativeEvent() {
        let plottableEvents: [MockPlottableEvent] = [
            MockPlottableEvent(amount: 70, date: Date().add(day: -2)),
            MockPlottableEvent(amount: 60, date: Date().add(day: -1)),
            MockPlottableEvent(amount: 50, date: Date())
        ]
        let dataSource = GraphViewDataSource(currentValue: 100, plottableEvents: plottableEvents, currency: currency)

        XCTAssertEqual(dataSource.numberOfPoints(), 4)
        XCTAssertEqual(dataSource.value(forPlot: plot, atIndex: 0), 0)
        XCTAssertEqual(dataSource.value(forPlot: plot, atIndex: 1), 0)
        XCTAssertEqual(dataSource.value(forPlot: plot, atIndex: 2), 50)
        XCTAssertEqual(dataSource.value(forPlot: plot, atIndex: 3), 100)
    }
}

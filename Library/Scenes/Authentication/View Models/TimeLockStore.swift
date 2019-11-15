//
//  Library
//
//  Created by Otto Suess on 29.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Lightning

/**
 Responsible for keeping track of invalid pin entries by the user and the
 resulting state of the wallet.
 Uses exponential backoff to lock wallet.
 */
class TimeLockStore: Persistable {
    private enum Constants {
        #if targetEnvironment(simulator)
        static let firstLockDuration: TimeInterval = 2
        #else
        static let firstLockDuration: TimeInterval = 60
        #endif
        static let numberOfTriesAllowed = 3
    }
    
    struct StoredData: Codable {
        fileprivate var currentLockDuration: TimeInterval
        fileprivate var wrongPinCounter: Int
        fileprivate var timeLockEnd: Date?
    }

    // Persistable
    typealias Value = StoredData
    static var fileName = "timeLockStore"
    var data: Value = StoredData(currentLockDuration: Constants.firstLockDuration, wrongPinCounter: 0, timeLockEnd: nil) {
        didSet {
            savePersistable()
        }
    }

    var timeLockEnd: Date? {
        return data.timeLockEnd
    }

    init() {
        loadPersistable()
    }

    var isLocked: Bool {
        guard let timeLockEnd = data.timeLockEnd else { return false }
        return timeLockEnd > Date()
    }

    func increase() {
        data.wrongPinCounter += 1
        if data.wrongPinCounter >= Constants.numberOfTriesAllowed {
            data.timeLockEnd = Date(timeIntervalSinceNow: data.currentLockDuration)
            data.currentLockDuration *= 2 // exponential backoff
            data.wrongPinCounter = 0
        }
    }

    func reset() {
        data.wrongPinCounter = 0
        data.currentLockDuration = Constants.firstLockDuration
    }

    private var timer: Timer?

    func whenUnlocked(completion: @escaping () -> Void) {
        guard let waitInterval = data.timeLockEnd?.timeIntervalSince(Date()),
            waitInterval > 0 else {
                completion()
                return
        }

        timer = Timer.scheduledTimer(withTimeInterval: waitInterval, repeats: false) { _ in
            completion()
        }
    }
}

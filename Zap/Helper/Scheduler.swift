//
//  Zap
//
//  Created by Otto Suess on 21.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Foundation

@objc protocol SchedulerJob {
    func run()
}

final class Task: SchedulerJob {
    let action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    @objc
    func run() {
        action()
    }
}

final class Scheduler {
    private static var jobs: [SchedulerJob] = []
    
    static func schedule(interval: TimeInterval, job: SchedulerJob) -> Timer {
        guard Thread.isMainThread else { fatalError("'schedule' called from wrong thread.") }
        
        let timer = Timer.scheduledTimer(timeInterval: interval, target: job, selector: #selector(job.run), userInfo: nil, repeats: true)
        job.run()
        jobs.append(job)
        
        return timer
    }
    
    static func schedule(interval: TimeInterval, action: @escaping () -> Void) -> Timer {
        let task = Task(action: action)
        return schedule(interval: interval, job: task)
    }
    
    static func job<T: SchedulerJob>() -> T? {
        for job in jobs where job is T {
            return job as? T
        }
        return nil
    }
}

final class BlockChainHeightJob: SchedulerJob {
    private struct BlockHeightJSON: Decodable {
        let blockCount: Int
        
        private enum CodingKeys: String, CodingKey {
            case blockCount = "blockcount"
        }
    }
    
    let handler: (Int) -> Void
    
    init(handler: @escaping (Int) -> Void) {
        self.handler = handler
    }

    func run() {
        guard let url = URL(string: "https://testnet.blockexplorer.com/api/status?q=getBlockCount") else { fatalError("Invalid url") }
        Json.fetch(url: url) { [weak self] (json: BlockHeightJSON) in
            self?.handler(json.blockCount)
        }
    }
}

//
//  Library
//
//  Created by 0 on 24.04.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

final class FileObserver {
    let source: DispatchSourceFileSystemObject

    init?(path: String, writeHandler: @escaping (String) -> Void) {
        let descriptor = open(path, O_EVTONLY)
        guard descriptor != -1 else { return nil }

        let eventSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: descriptor, eventMask: DispatchSource.FileSystemEvent.write, queue: DispatchQueue.main)

        eventSource.setEventHandler {
            writeHandler(path)
        }

        eventSource.setCancelHandler { close(descriptor) }

        eventSource.resume()

        self.source = eventSource
    }
}

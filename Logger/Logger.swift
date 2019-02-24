//
//  Library
//
//  Created by Otto Suess on 15.02.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

public enum Logger {
    public enum Level: String {
        case verbose = "ℹ️"
        case info = "💡"
        case warning = "⚠️"
        case error = "🆘"
    }

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        return dateFormatter
    }()

    private static var time: String {
        return dateFormatter.string(from: Date())
    }

    public static func verbose(_ message: Any, customPrefix: String? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .verbose, message, customPrefix: customPrefix, file: file, function: function, line: line)
    }

    public static func info(_ message: Any, customPrefix: String? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .info, message, customPrefix: customPrefix, file: file, function: function, line: line)
    }

    public static func warn(_ message: Any, customPrefix: String? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .warning, message, customPrefix: customPrefix, file: file, function: function, line: line)
    }

    public static func error(_ message: Any, customPrefix: String? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .error, message, customPrefix: customPrefix, file: file, function: function, line: line)
    }

    private static func log(level: Level = .info, _ message: Any, customPrefix: String? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        let source = "- (\(sourceFileName(filePath: file)).\(function):\(line))"
        // swiftlint:disable:next print
        print(time, customPrefix ?? level.rawValue, message, source)
    }

    private static func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.last?.components(separatedBy: ".").first ?? ""
    }
}

//
//  Library
//
//  Created by 0 on 24.04.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

enum LogFormatter {
    private static let font = UIFont(name: "Courier", size: 13) ?? UIFont.systemFont(ofSize: 13)

    static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter
    }()

    static var outputDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter
    }()

    static func format(string: String) -> NSAttributedString {
        return string.components(separatedBy: .newlines).suffix(100)
            .compactMap {
                let dateCount = 23
                var dateString = ""
                if let date = LogFormatter.dateFormatter.date(from: String($0.prefix(dateCount))) {
                    dateString = LogFormatter.outputDateFormatter.string(from: date)
                }

                let string = dateString + String($0.dropFirst(dateCount))

                let result = NSMutableAttributedString(string: string + "\n", attributes: [
                    .font: font
                ])

                let dateRange = NSRange(location: 0, length: min(dateString.count, string.count))
                result.addAttribute(.foregroundColor, value: UIColor.darkGray, range: dateRange)

                guard let regex = try? NSRegularExpression(pattern: "^.*\\[.*\\] [A-Z]*:", options: .caseInsensitive) else { return nil }
                for match in regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.count)) {
                    result.addAttribute(.backgroundColor, value: UIColor.lightGray, range: match.range)
                }

                return result
            }
            .reduce(NSMutableAttributedString(), { (result: NSMutableAttributedString, line: NSMutableAttributedString) -> NSMutableAttributedString in
                result.append(line)
                return result
            })
    }
}

//
//  String+Emoji.swift
//  emoji-swift
//
//  Created by Safx Developer on 2015/04/07.
//  Copyright (c) 2015 Safx Developers. All rights reserved.
//

import Foundation


extension String {

    public static var emojis = emoji {
        didSet {
            emojiUnescapeRegExp = createEmojiUnescapeRegExp()
            emojiEscapeRegExp = createEmojiEscapeRegExp()
        }
    }

    fileprivate static var emojiUnescapeRegExp = createEmojiUnescapeRegExp()
    fileprivate static var emojiEscapeRegExp = createEmojiEscapeRegExp()

    fileprivate static func createEmojiUnescapeRegExp() -> NSRegularExpression {
        return try! NSRegularExpression(pattern: emojis.map { ":\($0.shortname):" } .joined(separator: "|"), options: [])
    }

    fileprivate static func createEmojiEscapeRegExp() -> NSRegularExpression {
        let v = emojis.flatMap { $0.codepoints }.sorted().reversed()
        return try! NSRegularExpression(pattern: v.joined(separator: "|"), options: [])
    }
    
    public var emojiUnescapedString: String {
        var s = self as NSString
        let ms = String.emojiUnescapeRegExp.matches(in: self, options: [], range: NSMakeRange(0, s.length))
        ms.reversed().forEach { m in
            let r = m.range
            let p = s.substring(with: r)
            let px = p[p.index(after: p.startIndex) ..< p.index(before: p.endIndex)]
            let index = String.emojis.index { $0.shortname == px } // TODO: create dictionary
            if let i = index {
                let e = String.emojis[i]
                s = s.replacingCharacters(in: r, with: e.codepoints.first!) as NSString
            }
        }
        return s as String
    }

    public var emojiEscapedString: String {
        var s = self as NSString
        let ms = String.emojiEscapeRegExp.matches(in: self, options: [], range: NSMakeRange(0, s.length))
        ms.reversed().forEach { m in
            let r = m.range
            let p = s.substring(with: r)
            let index = String.emojis.index { $0.codepoints.index { $0 == p } != nil } // TODO: create dictionary
            if let i = index {
                let e = String.emojis[i]
                s = s.replacingCharacters(in: r, with: ":\(e.shortname):") as NSString
            }
        }
        return s as String
    }

}

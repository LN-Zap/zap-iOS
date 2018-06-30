//
//  Zap
//
//  Created by Otto Suess on 18.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

public enum TransactionAnnotationType {
    case openChannelTransaction(String)
}

extension TransactionAnnotationType: Codable {
    enum CodingKeys: String, CodingKey {
        case openChannelTransaction
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self = .openChannelTransaction(try container.decode(String.self, forKey: .openChannelTransaction))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .openChannelTransaction(let value):
            try container.encode(value, forKey: .openChannelTransaction)
        }
    }
}

public struct TransactionAnnotation: Codable {
    public let isHidden: Bool
    public let customMemo: String?
    public let type: TransactionAnnotationType?
    
    func settingHidden(to isHidden: Bool) -> TransactionAnnotation {
        return TransactionAnnotation(isHidden: isHidden, customMemo: customMemo, type: type)
    }
    
    public func settingMemo(to customMemo: String?) -> TransactionAnnotation {
        var memo = customMemo?.trimmingCharacters(in: .whitespacesAndNewlines)
        if memo == "" {
            memo = nil
        }
        return TransactionAnnotation(isHidden: isHidden, customMemo: memo, type: type)
    }
}

extension TransactionAnnotation {
    init() {
        isHidden = false
        customMemo = nil
        type = nil
    }
}

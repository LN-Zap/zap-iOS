//
//  Zap
//
//  Created by Otto Suess on 18.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

public enum TransactionAnnotationType {
    case openChannelTransaction(remotePubKey: String)
    case closeChannelTransaction(remotePubKey: String, type: CloseType)
}

extension TransactionAnnotationType: Codable {
    enum CodingKeys: String, CodingKey {
        case openChannelTransactionRemotePubKey
        case closeChannelTransactionRemotePubKey
        case closeChannelTransactionType
    }
    
    enum TransactionAnnotationTypeCodingError: Error {
        case decoding(String)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let remotePubKey = try? container.decode(String.self, forKey: .openChannelTransactionRemotePubKey) {
            self = .openChannelTransaction(remotePubKey: remotePubKey)
            return
        }
        
        if
            let remotePubKey = try? container.decode(String.self, forKey: .closeChannelTransactionRemotePubKey),
            let type = try? container.decode(CloseType.self, forKey: .closeChannelTransactionType) {
            self = .closeChannelTransaction(remotePubKey: remotePubKey, type: type)
            return
        }
        
        throw TransactionAnnotationTypeCodingError.decoding("Error decoding: \(dump(container))")
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .openChannelTransaction(let remotePubKey):
            try container.encode(remotePubKey, forKey: .openChannelTransactionRemotePubKey)
        case let .closeChannelTransaction(remotePubKey, type):
            try container.encode(remotePubKey, forKey: .closeChannelTransactionRemotePubKey)
            try container.encode(type, forKey: .closeChannelTransactionType)
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
    
    public func settingType(to type: TransactionAnnotationType) -> TransactionAnnotation {
        return TransactionAnnotation(isHidden: isHidden, customMemo: customMemo, type: type)
    }
}

extension TransactionAnnotation {
    init() {
        isHidden = false
        customMemo = nil
        type = nil
    }
}

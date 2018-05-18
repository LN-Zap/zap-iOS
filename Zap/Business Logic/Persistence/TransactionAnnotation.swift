//
//  Zap
//
//  Created by Otto Suess on 18.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

enum TransactionAnnotationType {
    case openChannelTransaction(String)
}

extension TransactionAnnotationType: Codable {
    enum CodingKeys: String, CodingKey {
        case openChannelTransaction
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self = .openChannelTransaction(try container.decode(String.self, forKey: .openChannelTransaction))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .openChannelTransaction(let value):
            try container.encode(value, forKey: .openChannelTransaction)
        }
    }
}

struct TransactionAnnotation: Codable {
    let isHidden: Bool
    let customMemo: String?
    
    let type: TransactionAnnotationType?
}

extension TransactionAnnotation {
    init() {
        isHidden = false
        customMemo = nil
        type = nil
    }
}

extension TransactionAnnotation {
    // swiftlint:disable:next type_name
    public enum lens {
        public static let isHidden = Lens<TransactionAnnotation, Bool>(
            view: { $0.isHidden },
            set: { .init(isHidden: $0, customMemo: $1.customMemo, type: $1.type) }
        )
        
        public static let customMemo = Lens<TransactionAnnotation, String?>(
            view: { $0.customMemo },
            set: { .init(isHidden: $1.isHidden, customMemo: $0, type: $1.type) }
        )
    }
}

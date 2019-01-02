//
//  SwiftLnd
//
//  Created by Otto Suess on 30.11.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

public struct Permissions {
    public struct AccessMode: OptionSet {
        public let rawValue: Int
        
        public static let read = AccessMode(rawValue: 1 << 0)
        public static let write = AccessMode(rawValue: 1 << 1)
        public static let generate = AccessMode(rawValue: 1 << 2)
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        static func fromString(_ string: String) -> AccessMode? {
            switch string {
            case "read":
                return .read
            case "write":
                return .write
            case "generate":
                return .generate
            default:
                return nil
            }
        }
    }
    
    public enum Domain: String, CaseIterable {
        case address
        case info
        case invoices
        case message
        case offChain = "offchain"
        case onChain = "onchain"
        case peers
        case signer
    }
    
    private let permissions: [Permissions.Domain: Permissions.AccessMode]
    
    public static var none: Permissions {
        return Permissions(permissions: [:])
    }
    
    public static var all: Permissions {
        var permissions = [Permissions.Domain: Permissions.AccessMode]()
        for domain in Domain.allCases {
            permissions[domain] = [.read, .write, .generate]
        }
        return Permissions(permissions: permissions)
    }
    
    init(permissions: [Permissions.Domain: Permissions.AccessMode]) {
        self.permissions = permissions
    }
    
    public func can(_ accessMode: Permissions.AccessMode, domain: Permissions.Domain) -> Bool {
        return permissions[domain]?.contains(accessMode) ?? false
    }
}

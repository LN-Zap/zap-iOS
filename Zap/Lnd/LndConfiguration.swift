//
//  Zap
//
//  Created by Otto Suess on 11.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

final class LndConfiguration: NSObject {
    var sections = [String: [String: String]]()
    
    static let standard: LndConfiguration = {
        let configuration = LndConfiguration()
        configuration.set("Application Options", key: "debuglevel", value: "debug")
        configuration.set("Application Options", key: "maxpendingchannels", value: "10")
        configuration.set("Application Options", key: "nobootstrap", value: "1")
        configuration.set("Application Options", key: "noencryptwallet", value: "1")
        configuration.set("Application Options", key: "alias", value: "Zap iOS")
        configuration.set("Application Options", key: "color", value: "#3399FF")
        
        configuration.set("Bitcoin", key: "bitcoin.active", value: "1")
        configuration.set("Bitcoin", key: "bitcoin.testnet", value: "1")
        configuration.set("Bitcoin", key: "bitcoin.node", value: "neutrino")
        
        configuration.set("neutrino", key: "neutrino.connect", value: "faucet.lightning.community")
        
        configuration.set("autopilot", key: "autopilot.active", value: "1")
        return configuration
    }()
    
    func set(_ section: String, key: String, value: String) {
        if sections[section] == nil {
            sections[section] = [key: value]
        } else {
            sections[section]?[key] = value
        }
    }
    
    var string: String {
        return sections.reduce("") {
            let lines = $1.1.reduce("") { $0 + "\($1.0)=\($1.1)\n" }
            return $0 + "[\($1.0)]\n\(lines)\n"
        }
    }
    
    func save(at path: URL) {
        let configurationDestination = path.appendingPathComponent("lnd.conf")
        try? string.write(to: configurationDestination, atomically: false, encoding: .utf8)
    }
}

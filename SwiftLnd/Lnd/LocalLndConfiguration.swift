//
//  Zap
//
//  Created by Otto Suess on 11.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import Logger

final class LocalLndConfiguration {
    var sections = [String: [(String, String)]]()

    private init() {}

    static let standard: LocalLndConfiguration = {
        let configuration = LocalLndConfiguration()
        configuration.set("Application Options", key: "debuglevel", value: "ATPL=debug,BRAR=debug,BTCN=info,CHDB=debug,CMGR=debug,CNCT=debug,CRTR=warn,DISC=debug,FNDG=debug,HSWC=debug,LNWL=debug,LTND=debug,NTFN=debug,PEER=info,RPCS=debug,SPHX=debug,SRVR=debug,UTXN=debug")
        configuration.set("Application Options", key: "maxpendingchannels", value: "10")
        configuration.set("Application Options", key: "nobootstrap", value: "1")
        configuration.set("Application Options", key: "nolisten", value: "1")
        configuration.set("Application Options", key: "alias", value: "Zap iOS")
        configuration.set("Application Options", key: "color", value: "#3399FF")

        configuration.set("Bitcoin", key: "bitcoin.active", value: "1")
        configuration.set("Bitcoin", key: "bitcoin.testnet", value: "1")
        configuration.set("Bitcoin", key: "bitcoin.node", value: "neutrino")

        configuration.set("neutrino", key: "neutrino.connect", value: "testnet1-btcd.zaphq.io")
        configuration.set("neutrino", key: "neutrino.connect", value: "testnet2-btcd.zaphq.io")

        configuration.set("autopilot", key: "autopilot.active", value: "0")
        return configuration
    }()

    private func set(_ section: String, key: String, value: String) {
        if sections[section] == nil {
            sections[section] = [(key, value)]
        } else {
            sections[section]?.append((key, value))
        }
    }

    private var string: String {
        return sections.reduce("") {
            let lines = $1.1.reduce("") { $0 + "\($1.0)=\($1.1)\n" }
            return $0 + "[\($1.0)]\n\(lines)\n"
        }
    }

    func save(at path: URL) {
        let configurationDestination = path.appendingPathComponent("lnd.conf")
        do {
            try string.write(to: configurationDestination, atomically: false, encoding: .utf8)
        } catch {
            Logger.error(error)
        }
    }
}

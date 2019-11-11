//
//  Zap
//
//  Created by Otto Suess on 11.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import Logger
import SwiftBTC

struct LocalLndConfiguration {
    var network = Network.testnet
    var alias = "Zap iOS"

    private var userAgentVersion: String? {
        guard
            let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
            else { return nil }
        return "\(versionNumber)-\(buildNumber)"
    }

    private typealias Configuration = [Section: [(String, String)]]

    private enum Section: String {
        case applicationOptions = "Application Options"
        case bitcoin = "Bitcoin"
        case neutrino = "Neutrino"
        case autopilot = "autopilot"
    }

    private var networkString: String {
        switch network {
        case .regtest:
            return "bitcoin.regtest"
        case .testnet:
            return "bitcoin.testnet"
        case .mainnet:
            return "bitcoin.mainnet"
        case .simnet:
            return "bitcoin.simnet"
        }
    }

    private var neutrinoNodes: [String] {
        switch network {
        case .mainnet:
            return ["mainnet1-btcd.zaphq.io", "mainnet2-btcd.zaphq.io"]
        case .testnet:
            return ["testnet1-btcd.zaphq.io", "testnet2-btcd.zaphq.io", "btcd-testnet.lightning.computer"]
        case .simnet, .regtest:
            return ["localhost"]
        }
    }

    private var configuration: Configuration {
        var configuration: Configuration = [
            .applicationOptions: [
                ("debuglevel", "ATPL=debug,BRAR=debug,BTCN=info,CHDB=debug,CMGR=debug,CNCT=debug,CRTR=warn,DISC=debug,FNDG=debug,HSWC=debug,LNWL=debug,LTND=debug,NTFN=debug,PEER=info,RPCS=debug,SPHX=debug,SRVR=debug,UTXN=debug"),
                ("no-macaroons", "1"),
                ("nolisten", "1"),
                ("norest", "1"),
                ("alias", alias),
                ("color", "#3399FF"),
                ("maxbackoff", "2s"),
                ("routing.assumechanvalid", "true"),
                ("ignore-historical-gossip-filters", "1"),
                ("restlisten", "0")
            ],
            .bitcoin: [
                ("bitcoin.active", value: "1"),
                (networkString, value: "1"),
                ("bitcoin.node", value: "neutrino")
            ],
            .neutrino: [
                ("neutrino.feeurl", value: "https://nodes.lightning.computer/fees/v1/btc-fee-estimates.json"),
                ("neutrino.useragentname", "zap-ios")
            ],
            .autopilot: [
                ("autopilot.active", value: "0")
            ]
        ]

        for node in neutrinoNodes {
            configuration[.neutrino]?.append(("neutrino.connect", value: node))
        }

        if let userAgentVersion = userAgentVersion {
            configuration[.neutrino]?.append(("neutrino.useragentversion", value: userAgentVersion))
        }

        return configuration
    }

    private func string(from configuration: Configuration) -> String {
        return configuration.reduce("") {
            let lines = $1.1.reduce("") { $0 + "\($1.0)=\($1.1)\n" }
            return $0 + "[\($1.0.rawValue)]\n\(lines)\n"
        }
    }

    func save(at path: URL) {
        let configurationDestination = path.appendingPathComponent("lnd.conf")
        do {
            let configString = string(from: configuration)
            Logger.info(configString)
            try configString.write(to: configurationDestination, atomically: false, encoding: .utf8)
        } catch {
            Logger.error(error)
        }
    }
}

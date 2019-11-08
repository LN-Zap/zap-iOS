//
//  Library
//
//  Created by Otto Suess on 01.02.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import KeychainAccess
import Lightning
import Logger
import ReactiveKit
import SwiftBTC
import SwiftLnd

struct WalletConfiguration: Equatable, Codable {
    let alias: String
    let network: Network
    let connection: LightningConnection
    let nodePubKey: String?
}

final class WalletConfigurationStore {
    private struct CodableData: Codable {
        let configurations: [WalletConfiguration]
        let selectedWallet: WalletConfiguration?
    }

    private static let keychain = Keychain(serviceExtension: "wallets").accessibility(.whenUnlocked)
    private static let keychainWalletConfigurationKey = "WalletConfiguration"

    private var infoBag: Disposable?
    private var codableData: CodableData {
        return CodableData(configurations: configurations, selectedWallet: selectedWallet)
    }
    var isEmpty: Bool {
        return configurations.isEmpty
    }
    private(set) var configurations: [WalletConfiguration]
    var selectedWallet: WalletConfiguration? { // make lighting connection
        didSet {
            save()
        }
    }

    var hasLocalWallet: Bool {
        return configurations.contains { $0.connection == .local }
    }

    var hasRemoteWallet: Bool {
        return configurations.contains { $0.connection != .local }
    }

    // used for UI tests
    static var mock: WalletConfigurationStore {
        guard
            let macaroon = Macaroon(hexadecimalString: "01"),
            let url = URL(string: "127.0.0.1:10009")
            else { fatalError("Invalid mock data") }
        let rpcCredentials = RPCCredentials(certificate: "01", macaroon: macaroon, host: url)
        let wallet = WalletConfiguration(alias: "mock alias", network: .mainnet, connection: .remote(rpcCredentials), nodePubKey: "123")
        return WalletConfigurationStore(configurations: [wallet], selectedWallet: wallet)
    }

    private init(configurations: [WalletConfiguration], selectedWallet: WalletConfiguration?) {
        self.configurations = configurations
        self.selectedWallet = selectedWallet
    }

    static func load() -> WalletConfigurationStore {
        if Environment.useUITestMockApi {
            return mock
        }

        guard let data = WalletConfigurationStore.keychain[data: keychainWalletConfigurationKey] else { return WalletConfigurationStore(data: nil) }
        let result = try? JSONDecoder().decode(CodableData.self, from: data)

        return WalletConfigurationStore(data: result)
    }

    private init(data: CodableData?) {
        var configurations = data?.configurations ?? []
        var selectedWallet = data?.selectedWallet

        // if there is a local wallet in the keychain, but not on disk, remove
        // the local wallet from the loaded list.
        if let localNetwork = FileManager.default.hasLocalWallet {
            if !configurations.contains { $0.connection == .local } {
                configurations.append(WalletConfiguration(alias: "Zap iOS", network: localNetwork, connection: .local, nodePubKey: nil))
            }
        } else {
            configurations.removeAll { $0.connection == .local }

            if selectedWallet?.connection == .local {
                selectedWallet = nil
            }
        }

        self.configurations = configurations
        sortConfigurations()

        self.selectedWallet = selectedWallet
    }

    func isSelected(walletConfiguration: WalletConfiguration) -> Bool {
        return walletConfiguration.nodePubKey == selectedWallet?.nodePubKey
    }

    func removeWallet(at index: Int) {
        let configuration = configurations[index]
        removeConfiguration(configuration)
    }

    func removeConfiguration(_ configuration: WalletConfiguration) {
        configurations.removeAll { $0 == configuration }
        if isSelected(walletConfiguration: configuration) {
            selectedWallet = nil
        }

        save()
    }

    func updateConnection(_ connection: LightningConnection, infoService: InfoService) {
        infoBag?.dispose()
        self.infoBag = infoService.info
            .ignoreNils()
            .observeNext { [weak self] info in
                self?.update(info: info, for: connection)
                self?.infoBag?.dispose()
            }
    }

    private func update(info: Info, for connection: LightningConnection) {
        let configuration = WalletConfiguration(alias: info.alias, network: info.network, connection: connection, nodePubKey: info.pubKey)

        configurations.removeAll { $0.connection == connection }
        configurations.append(configuration)
        sortConfigurations()

        selectedWallet = configuration

        save()
    }

    private func save() {
        let keychain = WalletConfigurationStore.keychain
        guard
            let data = try? JSONEncoder().encode(codableData)
            else { return }
        keychain[data: WalletConfigurationStore.keychainWalletConfigurationKey] = data
    }

    private func sortConfigurations() {
        configurations.sort(by: { $0.alias < $1.alias })
    }
}

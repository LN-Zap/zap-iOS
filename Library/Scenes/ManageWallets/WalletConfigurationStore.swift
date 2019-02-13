//
//  Library
//
//  Created by Otto Suess on 01.02.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import KeychainAccess
import Lightning
import ReactiveKit
import SwiftBTC
import SwiftLnd

struct WalletConfiguration: Equatable, Codable {
    let alias: String?
    let network: Network?
    let connection: LightningConnection
    let walletId: WalletId
    
    func updatingInfo(info: Info) -> WalletConfiguration {
        return WalletConfiguration(alias: info.alias, network: info.network, connection: connection, walletId: walletId)
    }
}

final class WalletConfigurationStore {
    private struct CodableData: Codable {
        let configurations: [WalletConfiguration]
        let selectedWallet: WalletConfiguration?
    }
    
    private static let keychain = Keychain(service: "com.jackmallers.zap.wallets").accessibility(.whenUnlocked)
    private static let keychainWalletConfigurationKey = "WalletConfiguration"
    
    private var infoBag: Disposable?
    private var codableData: CodableData {
        return CodableData(configurations: configurations, selectedWallet: selectedWallet)
    }
    var isEmpty: Bool {
        return configurations.isEmpty
    }
    private(set) var configurations: [WalletConfiguration]
    var selectedWallet: WalletConfiguration? {
        didSet {
            save()
        }
    }
    
    static func load() -> WalletConfigurationStore {
        guard let data = WalletConfigurationStore.keychain[data: keychainWalletConfigurationKey] else { return WalletConfigurationStore(data: nil) }
        let result = try? JSONDecoder().decode(CodableData.self, from: data)

        return WalletConfigurationStore(data: result)
    }
    
    private init(data: CodableData?) {
        configurations = data?.configurations ?? []
        sortConfigurations()
        selectedWallet = data?.selectedWallet
    }
    
    func removeWallet(at indexPath: IndexPath) {
        let walletId = configurations[indexPath.row].walletId
        guard let url = FileManager.default.walletDirectory(for: walletId) else { return }
        
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("🤮 removeWallet: \(error.localizedDescription)")
        }
        
        configurations.remove(at: indexPath.row)
        
        save()
    }
    
    func addWallet(walletConfiguration: WalletConfiguration) {
        guard !configurations.contains(where: {
            guard $0.walletId != walletConfiguration.walletId else { return true }
            
            // it's possible to have multiple wallets with configuration
            // `.local`, but we don't want multiple `.remote` wallets with same
            // `RemoteRPCConfiguration`
            switch ($0.connection, walletConfiguration.connection) {
            case let (.remote(oldConnection), .remote(newConnection)):
                return oldConnection == newConnection
            #if !REMOTEONLY
            default:
                return false
            #endif
            }
        }) else { return }
        configurations.append(walletConfiguration)
        sortConfigurations()
        selectedWallet = walletConfiguration
        
        save()
    }
    
    func updateInfo(for configuration: WalletConfiguration, infoService: InfoService) {
        infoBag?.dispose()
        self.infoBag = infoService.info
            .ignoreNil()
            .observeNext { [weak self] info in
                self?.update(info: info, for: configuration)
            }
    }

    private func update(info: Info, for configuration: WalletConfiguration) {
        guard let oldConfiguration = configurations.first(where: { $0.walletId == configuration.walletId }) else { return }
        
        configurations.removeAll { $0.walletId == configuration.walletId }
        
        configurations.append(oldConfiguration.updatingInfo(info: info))
        sortConfigurations()
        infoBag?.dispose()
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
        configurations.sort(by: { $0.alias ?? "" < $1.alias ?? "" })
    }
}

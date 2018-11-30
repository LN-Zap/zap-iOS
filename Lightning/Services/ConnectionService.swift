//
//  ZapShared
//
//  Created by Otto Suess on 26.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import SwiftLnd

public final class ConnectionService: NSObject {
    public enum State {
        case noWallet
        case connecting
        case noInternet
        case syncing
        case running
    }
    
    public let state = Observable<State>(.connecting)
    
    public var permissions: Permissions {
        switch LightningConnection.current {
        case .none:
            return Permissions.none
        case .remote(let connection):
            return connection.macaroon.permissions
        }
    }
    
    private var connectionTimeoutTimer: Timer?
    private var syncingStartTime: Date?
    
    public private(set) var lightningService: LightningService? {
        didSet {
            bindStateToLnd()
        }
    }
    public var walletService: WalletService {
        return WalletService(connection: LightningConnection.current)
    }

    public func start() {
        setInitialState()
    }
    
    private func setInitialState() {
        switch LightningConnection.current {
        case .none:
            state.value = .noWallet
        default:
            state.value = .connecting
            connect()
        }
    }
    
    public func stop() {
        lightningService?.stop()
        LocalLnd.stop()
    }
    
    public func connect() {
        state.value = .connecting
        
        let connection = LightningConnection.current
        
        #if !REMOTEONLY
        if case .local = connection {
            walletService.unlockWallet { _ in }
        }
        #endif
        
        guard let lightningService = LightningService(connection: connection) else { return }
        self.lightningService = lightningService
        lightningService.start()
        
        connectionTimeoutTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
            self?.connectionTimeoutTimer = nil
            self?.state.value = .noWallet
        }
    }
    
    public func disconnect() {
        self.lightningService = nil
        lightningService?.stop()
        state.value = .noWallet
    }
    
    public func reconnect(configuration: RemoteRPCConfiguration) {
        configuration.save()
        self.lightningService = nil
        lightningService?.stop()
        connect()
    }
        
    private func bindStateToLnd() {
        _ = lightningService?.infoService.walletState
            .skip(first: 1)
            .filter(filterSyncing)
            .distinct()
            .map(stateForInfoState)
            .feedNext(into: state)
            .observeNext { [weak self] _ in
                self?.connectionTimeoutTimer?.invalidate()
                self?.connectionTimeoutTimer = nil
            }
            .dispose(in: reactive.bag)
    }
    
    private func stateForInfoState(_ state: InfoService.State) -> ConnectionService.State {
        switch state {
        case .connecting:
            return handleConnectingState()
        case .noInternet:
            return .noInternet
        case .syncing:
            return .syncing
        case .running:
            return .running
        }
    }
    
    private func handleConnectingState() -> State {
        if case .remote = LightningConnection.current {
            lightningService?.stop()
            lightningService = nil
            return .noWallet
        } else {
            return .connecting
        }
    }
    
    // add 3 second debounce to syncing, so we don't switch to sync screen when the app is running and a new block is found.
    private func filterSyncing(newState: InfoService.State) -> Bool {
        if state.value == .running && newState == .syncing {
            if let syncingStartTime = syncingStartTime {
                if syncingStartTime.addingTimeInterval(3) < Date() {
                    self.syncingStartTime = nil
                    return true
                }
            } else {
                syncingStartTime = Date()
            }
            return false
        }
        return true
    }
}

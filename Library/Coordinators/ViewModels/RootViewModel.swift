//
//  ZapShared
//
//  Created by Otto Suess on 26.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning

final class RootViewModel: NSObject {
    let authenticationViewModel = AuthenticationViewModel()
    
    enum State {
        case locked
        case noWallet
        case connecting
        case noInternet
        case syncing
        case running
    }
    
    let state = Observable<State>(.connecting)
    
    private(set) var lightningService: LightningService? {
        didSet {
            bindStateToLnd()
        }
    }
    var walletService: WalletService {
        return WalletService(wallet: WalletApiStream())
    }

    func start() {
        ExchangeUpdaterJob.start()

        switch LndConnection.current {
        case .none:
            state.value = .noWallet
        default:
            if Environment.skipPinFlow {
                state.value = .connecting
                connect()
            } else {
                state.value = .locked
            }
        }
    }
    
    func stop() {
        ExchangeUpdaterJob.stop()
        lightningService?.stop()
        LocalLnd.stop()
    }
    
    func connect() {
        let connection = LndConnection.current
        
        if case .local = LndConnection.current {
            walletService.unlockWallet { _ in }
        }
        
        guard let lightningService = LightningService(connection: connection) else { return }
        lightningService.start()
        self.lightningService = lightningService
    }
    
    private func bindStateToLnd() {
        lightningService?.infoService.walletState
            .skip(first: 1)
            .distinct()
            .observeOn(DispatchQueue.main)
            .observeNext { [weak self] infoServiceState in
                guard let strongSelf = self else { return }
                strongSelf.state.value = strongSelf.state(for: infoServiceState)
            }
            .dispose(in: reactive.bag)
    }
    
    private func state(for state: InfoService.State) -> RootViewModel.State {
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
        if case .remote = LndConnection.current {
            lightningService?.stop()
            lightningService = nil
            return .noWallet
        } else {
            return .connecting
        }
    }
}

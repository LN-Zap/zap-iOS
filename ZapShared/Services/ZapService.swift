//
//  ZapShared
//
//  Created by Otto Suess on 26.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

final class ZapService: NSObject {
    
    enum State {
        case locked
        case noWallet
        case loading(message: LoadingViewController.Message)
        case syncing
        case running
    }
    
    let state = Observable<State>(.loading(message: .none))
    
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
            if Environment.skipPinFlow || !AuthenticationService.shared.didSetupPin {
                state.value = .loading(message: .none)
                connect()
            } else {
                state.value = .locked
            }
        }
    }
    
    func connect() {
        guard let api = LndConnection.current.api else { return }
        
        if case .local = LndConnection.current {
            walletService.unlockWallet { _ in }
        }
        
        let lightningService = LightningService(api: api)
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
    
    private func state(for state: InfoService.State) -> ZapService.State {
        switch state {
        case .connecting:
            return handleConnectingState()
        case .noInternet:
            return .loading(message: .noInternet)
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
            return .loading(message: .none)
        }
    }
}

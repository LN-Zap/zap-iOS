//
//  ZapShared
//
//  Created by Otto Suess on 26.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning

public final class RootViewModel: NSObject {
    
    public enum State {
        case locked
        case noWallet
        case connecting
        case noInternet
        case syncing
        case running
    }
    
    public let state = Observable<State>(.connecting)
    
    public private(set) var lightningService: LightningService? {
        didSet {
            bindStateToLnd()
        }
    }
    public var walletService: WalletService {
        return WalletService(wallet: WalletApiStream())
    }

    public func start() {
        switch LndConnection.current {
        case .none:
            state.value = .noWallet
        default:
            if Environment.skipPinFlow || !AuthenticationViewModel.shared.didSetupPin {
                state.value = .connecting
                connect()
            } else {
                state.value = .locked
            }
        }
    }
    
    public func connect() {
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

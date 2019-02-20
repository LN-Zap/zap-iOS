//
//  Zap
//
//  Created by Otto Suess on 03.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning
import ReactiveKit
import SwiftLnd

final class ConnectRemoteNodeViewModel: NSObject {
    enum CellType: Equatable {
        case emptyState
        case address(String)
        case certificate(String)
        case connect
        case scan
        case paste
        case help
    }
    
    var remoteNodeConfiguration: RemoteRPCConfiguration? {
        didSet {
            updateTableView()
        }
    }
    
    let dataSource: MutableObservable2DArray<String?, CellType>
    
    private var testServer: LightningApiRPC?
    
    override private init() {
        fatalError("not implemented")
    }
    
    init(remoteRPCConfiguration: RemoteRPCConfiguration?) {
        dataSource = MutableObservable2DArray([])
        
        super.init()
        
        self.remoteNodeConfiguration = remoteRPCConfiguration
        updateTableView()
    }
    
    private func updateTableView() {
        let sections = MutableObservable2DArray<String?, ConnectRemoteNodeViewModel.CellType>()
        
        if let configuration = remoteNodeConfiguration {
            sections.appendSection(certificateSection(for: configuration))
        } else {
            sections.appendSection(Observable2DArraySection<String?, CellType>(
                metadata: L10n.Scene.ConnectRemoteNode.yourNodeTitle,
                items: [.emptyState]
            ))
        }
        
        sections.appendSection(Observable2DArraySection<String?, CellType>(
            metadata: nil,
            items: [.scan, .paste]
        ))
        sections.appendSection(Observable2DArraySection<String?, CellType>(
            metadata: nil,
            items: [.help]
        ))
        
        dataSource.replace(with: sections, performDiff: true)
    }
    
    private func certificateSection(for qrCode: RemoteRPCConfiguration) -> Observable2DArraySection<String?, CellType> {
        var items: [CellType] = [
            .address(qrCode.url.absoluteString),
            .connect
        ]
        
        if let certificateDescription = qrCode.certificate?
            .replacingOccurrences(of: "-----BEGIN CERTIFICATE-----", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines) {
            items.insert(.certificate(certificateDescription), at: 0)
        } else {
            items.insert(.certificate(qrCode.macaroon.hexadecimalString), at: 0)
        }
        
        return Observable2DArraySection<String?, CellType>(
            metadata: L10n.Scene.ConnectRemoteNode.yourNodeTitle,
            items: items
        )
    }
    
    func pasteCertificates(_ string: String, completion: @escaping (SwiftLnd.Result<Success, RPCConnectQRCodeError>) -> Void) {
        RPCConnectQRCode.configuration(for: string) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let configuration):
                    self?.remoteNodeConfiguration = configuration
                    completion(.success(Success()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func connect(completion: @escaping (WalletConfiguration, SwiftLnd.Result<Success, LndApiError>) -> Void) {
        guard let remoteNodeConfiguration = remoteNodeConfiguration else { return }

        testServer = LightningApiRPC(configuration: remoteNodeConfiguration)
        testServer?.canConnect {
            let configuration = WalletConfiguration(alias: nil, network: nil, connection: .remote(remoteNodeConfiguration), walletId: UUID().uuidString)
            completion(configuration, $0)
        }
    }
    
    func updateUrl(_ url: URL) {
        guard let remoteNodeConfiguration = remoteNodeConfiguration else { return }
        
        let newConfiguration = RemoteRPCConfiguration(
            certificate: remoteNodeConfiguration.certificate,
            macaroon: remoteNodeConfiguration.macaroon,
            url: url)
        
        self.remoteNodeConfiguration = newConfiguration
    }
}

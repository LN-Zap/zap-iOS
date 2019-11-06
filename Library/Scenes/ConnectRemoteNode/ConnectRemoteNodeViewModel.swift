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

    var rpcCredentials: RPCCredentials? {
        didSet {
            updateTableView()
        }
    }

    let dataSource: MutableObservableArray2D<String?, CellType>

    private var testServer: LightningApi?

    override private init() {
        fatalError("not implemented")
    }

    init(rpcCredentials: RPCCredentials?) {
        dataSource = MutableObservableArray2D(Array2D())

        super.init()

        self.rpcCredentials = rpcCredentials
        updateTableView()
    }

    private func updateTableView() {
        var sections = Array2D<String?, ConnectRemoteNodeViewModel.CellType>()

        if let configuration = rpcCredentials {
            sections.appendSection(certificateSection(for: configuration))
        } else {
            sections.appendSection(Array2D.Section(metadata: L10n.Scene.ConnectRemoteNode.yourNodeTitle, items: [.emptyState]))
        }

        sections.appendSection(Array2D<String?, ConnectRemoteNodeViewModel.CellType>.Section(metadata: nil, items: [.scan, .paste]))
        sections.appendSection(Array2D<String?, ConnectRemoteNodeViewModel.CellType>.Section(metadata: nil, items: [.help]))

        dataSource.replace(with: sections, performDiff: true, areEqual: Array2D.areEqual)
    }

    private func certificateSection(for qrCode: RPCCredentials) -> Array2D<String?, CellType>.Section {
        var items: [ConnectRemoteNodeViewModel.CellType] = [
            .address(qrCode.host.absoluteString),
            .connect
        ]

        if let certificateDescription = qrCode.certificate?
            .replacingOccurrences(of: "-----BEGIN CERTIFICATE-----", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines) {
            items.insert(.certificate(certificateDescription), at: 0)
        } else {
            items.insert(.certificate(qrCode.macaroon.hexadecimalString), at: 0)
        }

        return Array2D.Section(metadata: L10n.Scene.ConnectRemoteNode.yourNodeTitle, items: items)
    }

    func pasteCertificates(_ string: String, completion: @escaping (Swift.Result<Success, RPCConnectQRCodeError>) -> Void) {
        RPCConnectQRCode.configuration(for: string) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let configuration):
                    self?.rpcCredentials = configuration
                    completion(.success(Success()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func connect(completion: @escaping (ApiCompletion<LightningConnection>)) {
        guard let rpcCredentials = rpcCredentials else { return }

        if rpcCredentials.host.isOnion {
            OnionConnecter().start(progress: nil, completion: { [weak self] result in
                switch result {
                case .success(let urlSessionConfiguration):
                    self?.connectWithBootstrappedTor(testConnection: .tor(rpcCredentials, urlSessionConfiguration), completion: completion)
                case .failure:
                    completion(.failure(.unknownError))
                }
            })
        } else {
            connectWithBootstrappedTor(testConnection: .grpc(rpcCredentials), completion: completion)
        }
    }

    private func connectWithBootstrappedTor(testConnection: LightningApi.Kind, completion: @escaping (ApiCompletion<LightningConnection>)) {
        guard let rpcCredentials = rpcCredentials else { return }

        testServer = LightningApi(connection: testConnection)
        testServer?.info { result in
            completion(result.map { _ in .remote(rpcCredentials) })
        }
    }

    func updateUrl(_ url: URL) {
        guard let rpcCredentials = rpcCredentials else { return }

        let newConfiguration = RPCCredentials(
            certificate: rpcCredentials.certificate,
            macaroon: rpcCredentials.macaroon,
            host: url)

        self.rpcCredentials = newConfiguration
    }
}

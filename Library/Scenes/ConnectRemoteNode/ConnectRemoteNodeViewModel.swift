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
    
    override init() {
        dataSource = MutableObservable2DArray([])
        
        super.init()
        
        remoteNodeConfiguration = RemoteRPCConfiguration.load()
        updateTableView()
    }
    
    private func updateTableView() {
        let sections = MutableObservable2DArray<String?, ConnectRemoteNodeViewModel.CellType>()
        
        if let configuration = remoteNodeConfiguration {
            sections.appendSection(certificateSection(for: configuration))
        } else {
            sections.appendSection(Observable2DArraySection<String?, CellType>(
                metadata: "scene.connect_remote_node.your_node_title".localized,
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
        
        let certificateDescription = qrCode.certificate
            .replacingOccurrences(of: "-----BEGIN CERTIFICATE-----", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let items: [CellType] = [
            .certificate(certificateDescription),
            .address(qrCode.url.absoluteString),
            .connect
        ]
        
        return Observable2DArraySection<String?, CellType>(
            metadata: "scene.connect_remote_node.your_node_title".localized,
            items: items
        )
    }
    
    func pasteCertificates() {
        guard
            let jsonString = UIPasteboard.general.string,
            let remoteNodeConfigurationQRCode = RemoteNodeConfigurationQRCode(json: jsonString)
            else { return }
        updateQRCode(remoteNodeConfigurationQRCode)
    }
    
    func updateQRCode(_ qrCode: RemoteNodeConfigurationQRCode) {
        remoteNodeConfiguration = RemoteRPCConfiguration(qrCode: qrCode)
    }
    
    func connect(callback: @escaping (Bool) -> Void) {
        guard let remoteNodeConfiguration = remoteNodeConfiguration else { return }

        remoteNodeConfiguration.save()

        testServer = LightningApiRPC(configuration: remoteNodeConfiguration)
        testServer?.canConnect(callback: callback)
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

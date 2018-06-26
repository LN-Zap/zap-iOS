//
//  Zap
//
//  Created by Otto Suess on 03.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit

final class ConnectRemoteNodeViewModel: NSObject {
    
    let isInputValid = Observable<Bool>(false)
    let urlString = Observable<String?>(nil)
    let certificatesString = Observable<String?>(nil)
    
    private var macaroon: Data?
    private var certificate: String?
    
    private var testServer: LightningApiRPC?
    
    override init() {
        super.init()
        
        combineLatest(urlString, certificatesString)
            .map { url, certificates -> Bool in
                // swiftlint:disable:next force_unwrapping
                url != nil && URL(string: url!) != nil && certificates != nil
            }
            .observeNext { [weak self] in
                self?.isInputValid.value = $0
            }
            .dispose(in: reactive.bag)
        
        if let savedConfiguration = RemoteRPCConfiguration.load() {
            updateUI(certificate: savedConfiguration.certificate, macaroon: savedConfiguration.macaroon, url: savedConfiguration.url)
        }
    }
    
    private func updateUI(certificate: String, macaroon: Data, url: URL?) {
        urlString.value = url?.absoluteString
        self.certificate = certificate
        self.macaroon = macaroon
        
        let macaroonString = macaroon.base64EncodedString()
        certificatesString.value = "\(certificate)\n\n\(macaroonString)"
    }
    
    func pasteCertificates() {
        guard
            let jsonString = UIPasteboard.general.string,
            let remoteNodeConfigurationQRCode = RemoteNodeConfigurationQRCode(json: jsonString)
            else { return }
        updateQRCode(remoteNodeConfigurationQRCode)
    }
    
    func updateQRCode(_ qrCode: RemoteNodeConfigurationQRCode) {
        updateUI(certificate: qrCode.certificate, macaroon: qrCode.macaroon, url: qrCode.url)
    }
    
    func connect(callback: @escaping (Bool) -> Void) {
        guard
            let urlString = urlString.value,
            let url = URL(string: urlString),
            let certificate = certificate,
            let macaroon = macaroon
            else { return }
        
        let remoteNodeConfiguration = RemoteRPCConfiguration(certificate: certificate, macaroon: macaroon, url: url)
        remoteNodeConfiguration.save()
        
        testServer = LightningApiRPC(configuration: remoteNodeConfiguration)
        testServer?.canConnect(callback: callback)
    }
}

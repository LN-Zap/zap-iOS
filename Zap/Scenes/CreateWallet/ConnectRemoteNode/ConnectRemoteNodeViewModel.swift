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
    
    var certificates: RemoteNodeCertificates? {
        didSet {
            updateCertificatesUI()
        }
    }
    
    private var testServer: LndRpcServer?
    
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
        
        let configuration = RemoteNodeConfiguration.load()
        certificates = configuration?.remoteNodeCertificates
        updateCertificatesUI()
        urlString.value = configuration?.url.absoluteString ?? Environment.defaultRemoteIP
    }
    
    private func updateCertificatesUI() {
        guard let certificates = certificates else { return }
        let certString: String = certificates.certificate
        let macString: String = certificates.macaron.base64EncodedString()
        
        certificatesString.value = "\(certString)\n\n\(macString)"
    }
    
    func pasteCertificates() {
        guard
            let jsonString = UIPasteboard.general.string,
            let remoteNodeCertificates = RemoteNodeCertificates(json: jsonString)
            else { return }
        
        certificates = remoteNodeCertificates
    }
    
    func connect(callback: @escaping (Bool) -> Void) {
        guard
            let urlString = urlString.value,
            let url = URL(string: urlString),
            let certificates = certificates
            else { return }
        
        let remoteNodeConfiguration = RemoteNodeConfiguration(remoteNodeCertificates: certificates, url: url)
        remoteNodeConfiguration.save()
        
        testServer = LndRpcServer(configuration: remoteNodeConfiguration)
        
        testServer?.canConnect(callback: callback)
    }
}

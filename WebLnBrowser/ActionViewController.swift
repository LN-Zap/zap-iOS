//
//  WebLnBrowser
//
//  Created by 0 on 28.02.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Lightning
import MobileCoreServices
import SwiftLnd
import UIKit
import WebKit

class ActionViewController: UIViewController {
    @IBOutlet private weak var navigationBar: UINavigationBar!
    @IBOutlet private weak var barNavigationItem: UINavigationItem!
    @IBOutlet private weak var webViewContainerView: UIView!
    private weak var webView: WKWebView!
    private var api: LightningApiRpc?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.tintColor = UIColor.Zap.lightningOrange
        view.backgroundColor = UIColor.Zap.background

        navigationBar.barTintColor = UIColor.Zap.background
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = false

        let logo = UIImage(named: "logo", in: Bundle.library, compatibleWith: nil)
        barNavigationItem.titleView = UIImageView(image: logo)

        webViewContainerView.backgroundColor = UIColor.Zap.background
        setupWebView()

        extensionContext?.url { [weak self] url in
            self?.webView.load(URLRequest(url: url))
        }
    }

    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.setURLSchemeHandler(self, forURLScheme: "lightning")

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = UIColor.Zap.background

        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: webViewContainerView.topAnchor),
            webView.bottomAnchor.constraint(equalTo: webViewContainerView.bottomAnchor),
            webView.leftAnchor.constraint(equalTo: webViewContainerView.leftAnchor),
            webView.rightAnchor.constraint(equalTo: webViewContainerView.rightAnchor)
        ])

        self.webView = webView

        #warning("put your lndconnectString here:")
        let lndConnectString = ""
        let lndConnectURL = LndConnectURL(string: lndConnectString)
        api = LightningApiRpc(configuration: lndConnectURL!.rpcCredentials)
    }

    @IBAction private func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
}

extension ActionViewController: WKURLSchemeHandler {
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url,
            url.scheme == "lightning"
            else { return }

        let decodingLoadingView = presentLoadingView(text: "")

        let prefix = "lightning:"
        var urlString = url.absoluteString
        if urlString.starts(with: prefix) {
            urlString = String(urlString.dropFirst(prefix.count))
        }

        api?.decodePaymentRequest(urlString) { [weak self] result in
            decodingLoadingView.dismiss()
            switch result {
            case .success(let paymentRequest):
                let alert = UIAlertController(title: "\(paymentRequest.amount) Satoshis", message: paymentRequest.memo, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                    urlSchemeTask.didReceive(HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!)
                    urlSchemeTask.didFinish()
                }))
                alert.addAction(UIAlertAction(title: "Send", style: .default) { _ in
                    let sendingLoadingView = self?.presentLoadingView(text: "Sending...")

                    self?.api?.sendPayment(paymentRequest, amount: nil) { result in
                        sendingLoadingView?.dismiss()

                        switch result {
                        case .success:
                            urlSchemeTask.didReceive(HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!)
                            urlSchemeTask.didFinish()
                        case .failure(let error):
                            print(error)
                            urlSchemeTask.didFailWithError(error)
                        }
                    }
                })
                self?.present(alert, animated: false)

            case .failure(let error):
                print(error)
                urlSchemeTask.didFailWithError(error)
            }
        }
    }

    enum WebErrors: Error {
        case requestFailedError
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        urlSchemeTask.didFailWithError(WebErrors.requestFailedError)
    }
}

extension NSExtensionContext {
    func url(completion: @escaping (URL) -> Void) {
        guard let items = inputItems as? [NSExtensionItem] else { return }

        for item in items {
            guard let providers = item.attachments else { continue }

            for provider in providers where provider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                provider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { url, _ in
                    guard let url = url as? URL else { return }
                    completion(url)
                }
                break
            }
        }
    }
}

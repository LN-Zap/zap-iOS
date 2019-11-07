//
//  Zap
//
//  Created by Otto Suess on 09.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
import SwiftBTC
import UIKit

final class LndLogViewController: UIViewController {
    @IBOutlet private weak var textView: UITextView!
    private var timer: Timer?

    private var fileObserver: FileObserver?

    private var network: Network! // swiftlint:disable:this implicitly_unwrapped_optional

    private var url: URL? {
        guard let folder = FileManager.default.walletDirectory else { return nil }
        return folder.appendingPathComponent("logs/bitcoin/\(network.rawValue)/lnd.log")
    }

    private var log: String? {
        guard let url = url else { return nil }
        return try? String(contentsOf: url)
    }

    static func instantiate(network: Network) -> LndLogViewController {
        let viewController = StoryboardScene.LndLog.lndLogViewController.instantiate()
        viewController.network = network
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        textView.font = UIFont(name: "Courier", size: 10)
        textView.isEditable = false
        textView.autocorrectionType = .no
        textView.backgroundColor = .white

        updateLog()

        guard let path = url?.path else { return }
        fileObserver = FileObserver(path: path) { [weak self] _ in
            self?.updateLog()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToBottom()
    }

    private func updateLog() {
        guard let log = self.log else { return }
        self.textView.attributedText = LogFormatter.format(string: log)
        scrollToBottom()
    }

    private func scrollToBottom() {
        let bottom = NSRange(location: self.textView.text.count - 1, length: 1)
        self.textView.scrollRangeToVisible(bottom)
    }

    @IBAction private func shareLog(_ sender: Any) {
        guard let log = log else { return }
        let activityViewController = UIActivityViewController(activityItems: [log], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
}

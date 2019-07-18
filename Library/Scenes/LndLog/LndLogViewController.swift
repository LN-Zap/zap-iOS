//
//  Zap
//
//  Created by Otto Suess on 09.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
import UIKit

final class LndLogViewController: UIViewController {
    @IBOutlet private weak var textView: UITextView!
    private var timer: Timer?

    // swiftlint:disable:next implicitly_unwrapped_optional
    private var walletConfiguration: WalletConfiguration!
    private var fileObserver: FileObserver?

    static func instantiate(walletConfiguration: WalletConfiguration) -> LndLogViewController {
        let viewController = StoryboardScene.LndLog.lndLogViewController.instantiate()
        viewController.walletConfiguration = walletConfiguration
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        textView.font = UIFont(name: "Courier", size: 10)
        textView.isEditable = false
        textView.autocorrectionType = .no

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

    private var url: URL? {
        guard let folder = FileManager.default.walletDirectory else { return nil }
        return folder.appendingPathComponent("logs/bitcoin/testnet/lnd.log")
    }

    private var log: String? {
        guard let url = url else { return nil }
        return try? String(contentsOf: url)
    }

    @IBAction private func shareLog(_ sender: Any) {
        guard let log = log else { return }
        let activityViewController = UIActivityViewController(activityItems: [log], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
}

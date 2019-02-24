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

    static func instantiate(walletConfiguration: WalletConfiguration) -> LndLogViewController {
        let viewController = StoryboardScene.LndLog.lndLogViewController.instantiate()
        viewController.walletConfiguration = walletConfiguration
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        textView.font = UIFont(name: "Courier", size: 10)

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateTextView()
        }

        textView.textColor = .white
        textView.backgroundColor = UIColor.Zap.background
    }

    private var log: String? {
        guard let folder = FileManager.default.walletDirectory(for: walletConfiguration.walletId) else { return nil }
        let url = folder.appendingPathComponent("logs/bitcoin/testnet/lnd.log")
        return try? String(contentsOf: url)
    }

    @objc private func updateTextView() {
        if let suffix = log?.suffix(10000) {
            textView.text = String(suffix)
        }

        let bottom = textView.contentSize.height - textView.bounds.size.height
        textView.setContentOffset(CGPoint(x: 0, y: bottom), animated: false)
    }

    @IBAction private func shareLog(_ sender: Any) {
        guard let log = log else { return }
        let activityViewController = UIActivityViewController(activityItems: [log], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
}

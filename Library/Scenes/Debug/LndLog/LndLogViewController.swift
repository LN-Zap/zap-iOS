//
//  Zap
//
//  Created by Otto Suess on 09.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static func instantiateDebugViewController() -> UINavigationController {
        return Storyboard.debug.initial(viewController: UINavigationController.self)
    }
}

final class LndLogViewController: UIViewController {
    @IBOutlet private weak var textView: UITextView!
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextStyle = .dark
        textView.font = UIFont(name: "Courier", size: 10)
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateTextView()
        }
    }
    
    private var log: String? {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("logs/bitcoin/testnet/lnd.log") else { return nil }
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
    
    @IBAction private func dismissViewController(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

//
//  Zap
//
//  Created by Otto Suess on 13.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
import SwiftLnd
import UIKit

final class LoadingViewController: UIViewController {
    enum Message {
        case none
    }

    @IBOutlet private weak var infoLabel: UILabel!

    private var message = Message.none

    static func instantiate(message: LoadingViewController.Message) -> LoadingViewController {
        let viewController = StoryboardScene.Loading.initialScene.instantiate()
        viewController.message = message
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.Zap.background

        Style.Label.custom().apply(to: infoLabel)
        infoLabel.textColor = .white

        switch message {
        case .none:
            infoLabel.text = nil
        }
    }
}

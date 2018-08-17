//
//  Library
//
//  Created by Otto Suess on 17.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class SendModalDetailViewController: ModalDetailViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        stackViewContent = [
            .label(text: "Lightning Payment Request", style: Style.Label.headline.with({ $0.textAlignment = .center })),
            .separator,
            .customHeight(56, element: .button(title: "Send xxx", style: Style.Button.background, callback: {
                print("send")
            }))
        ]
    }
}

//
//  Zap
//
//  Created by Otto Suess on 04.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class SettingsContainerViewController: UIViewController, ContainerViewController {
    @IBOutlet private weak var headerBackground: UIView!
    
    // swiftlint:disable:next private_outlet
    @IBOutlet weak var container: UIView?
    weak var currentViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
        
        headerBackground.backgroundColor = Color.darkBackground
        
        let viewController = SettingsViewController()
        setInitialViewController(viewController)
    }
    
    @IBAction private func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

//
//  Zap
//
//  Created by Otto Suess on 02.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class MainCoordinator {
    private let rootViewController: RootViewController
    private let viewModel: ViewModel
    
    init(rootViewController: RootViewController, viewModel: ViewModel) {
        self.rootViewController = rootViewController
        self.viewModel = viewModel
    }
    
    func start() {
        let viewController = UIStoryboard.instantiateMainViewController(with: viewModel)
        DispatchQueue.main.async {
            self.rootViewController.setContainerContent(viewController)
        }
    }
}

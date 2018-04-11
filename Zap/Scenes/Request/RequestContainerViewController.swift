//
//  Zap
//
//  Created by Otto Suess on 10.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class RequestContainerViewController: UIViewController, ContainerViewController {
    // swiftlint:disable:next private_outlet
    @IBOutlet weak var container: UIView?
    weak var currentViewController: UIViewController?

    @IBOutlet private weak var segmentedControlBackgroundView: UIView!
    @IBOutlet private weak var lightningButton: UIButton!
    @IBOutlet private weak var onChainButton: UIButton!
    
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    
    private var isLightningSelected: Bool = false {
        didSet {
            lightningButton.isSelected = isLightningSelected
            onChainButton.isSelected = !isLightningSelected
        }
    }
    
    var viewModel: ViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            self.lightningRequestViewModel = LightningRequestViewModel(viewModel: viewModel)
            self.onChainRequestQRCodeViewModel = OnChainRequestQRCodeViewModel(viewModel: viewModel)
        }
    }
    private var lightningRequestViewModel: LightningRequestViewModel?
    private var onChainRequestQRCodeViewModel: OnChainRequestQRCodeViewModel?
    
    private var lightningRequestViewController: LightningRequestViewController {
        let viewController = Storyboard.request.instantiate(viewController: LightningRequestViewController.self)
        viewController.lightningRequestViewModel = lightningRequestViewModel
        return viewController
    }
    
    private var requestBlockchainViewController: UIViewController {
        let viewController = Storyboard.qrCodeDetail.instantiate(viewController: QRCodeDetailViewController.self)
        viewController.viewModel = onChainRequestQRCodeViewModel
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Payment Request"
        
        lightningButton.setTitle("Lightning", for: .normal)
        onChainButton.setTitle("On-chain", for: .normal)

        lightningButton.isSelected = true
        
        segmentedControlBackgroundView.backgroundColor = Color.searchBackground
        
        setInitialViewController(lightningRequestViewController)
        
        setupKeyboardNotifications()
    }
    
    @IBAction private func segmentedControlDidChange(_ sender: UIButton) {
        isLightningSelected = sender == lightningButton
//        if isLightningSelected {
//            switchToViewController(lightningRequestViewController)
//        } else {
//            switchToViewController(requestBlockchainViewController)
//        }
    }
    
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.reactive.notification(name: .UIKeyboardWillHide)
            .observeNext { [weak self] _ in
                self?.updateKeyboardConstraint(to: 0)
            }
            .dispose(in: reactive.bag)
        
        NotificationCenter.default.reactive.notification(name: .UIKeyboardWillShow)
            .observeNext { [weak self] notification in
                guard
                    let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect
                    else { return }
                self?.updateKeyboardConstraint(to: keyboardFrame.height)
            }
            .dispose(in: reactive.bag)
    }
    
    private func updateKeyboardConstraint(to height: CGFloat) {
        UIView.animate(withDuration: 0.25) { [bottomConstraint, view] in
            bottomConstraint?.constant = height
            view?.layoutIfNeeded()
        }
    }
}

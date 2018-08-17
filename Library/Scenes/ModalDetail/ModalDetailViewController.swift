//
//  Library
//
//  Created by Otto Suess on 17.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class ModalDetailViewController: ModalViewController, QRCodeScannerChildViewController {
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var contentStackView: UIStackView!
    @IBOutlet private weak var headerIconImageView: UIImageView!
    
    weak var delegate: QRCodeScannerChildDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.clipsToBounds = false
        
        backgroundView.layer.cornerRadius = 14
        backgroundView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        contentStackView.spacing = 14
        contentStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)
        contentStackView.isLayoutMarginsRelativeArrangement = true
        
        headerIconImageView.image = UIImage(named: "icon_header_lightning", in: Bundle.library, compatibleWith: nil)
        headerIconImageView.alpha = 0
    }
    
    var contentSize: CGSize {
        var size = contentStackView?.systemLayoutSizeFitting(CGSize(width: 375, height: 0), withHorizontalFittingPriority: .defaultHigh, verticalFittingPriority: .defaultLow) ?? CGSize.zero
        size.height += 29 + 30
        return size
    }
    
    @IBAction private func changeSize(_ sender: Any) {
        let height: CGFloat = modalPresentationManager?.modalPresentationController?.contentHeight == 150 ? 400 : 150
        modalPresentationManager?.modalPresentationController?.contentHeight = height
    }
    
    @IBAction private func dismiss(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension ModalDetailViewController: ModalTransitionAnimating {
    func animatePresentationTransition() {
        headerIconImageView.alpha = 1
    }
    
    func animateDismissalTransition() {
        headerIconImageView.alpha = 0
    }
}

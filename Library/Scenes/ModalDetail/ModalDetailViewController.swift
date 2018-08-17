//
//  Library
//
//  Created by Otto Suess on 17.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class ModalDetailViewController: ModalViewController, QRCodeScannerChildViewController {
    private weak var backgroundView: UIView?
    private weak var contentStackView: UIStackView?
    private weak var headerIconImageView: UIImageView?
    
    weak var delegate: QRCodeScannerChildDelegate?
    
    var stackViewContent: [StackViewElement] = [] {
        didSet {
            contentStackView?.set(elements: stackViewContent)
            updateHeight()
        }
    }
    
    private func setupLayout() {
        let backgroundView = UIView(frame: CGRect.zero)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)
        backgroundView.constrainEdges(to: view)
        backgroundView.layer.cornerRadius = 14
        backgroundView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        backgroundView.backgroundColor = UIColor.Zap.seaBlue
        self.backgroundView = backgroundView
        
        let closeButton = UIButton(type: .custom)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage(named: "icon_close", in: Bundle.library, compatibleWith: nil), for: .normal)
        backgroundView.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 45),
            closeButton.heightAnchor.constraint(equalToConstant: 45),
            closeButton.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            closeButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor)
        ])
        closeButton.addTarget(self, action: #selector(dismissParent), for: .touchUpInside)
        
        let headerIconImageView = UIImageView(image: nil)
        headerIconImageView.translatesAutoresizingMaskIntoConstraints = false
        headerIconImageView.alpha = 0
        view.addSubview(headerIconImageView)
        NSLayoutConstraint.activate([
            headerIconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerIconImageView.centerYAnchor.constraint(equalTo: view.topAnchor)
        ])
        self.headerIconImageView = headerIconImageView
        
        let contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.spacing = 14
        contentStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 0, trailing: 20)
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(contentStackView)
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: headerIconImageView.bottomAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor)
        ])
        self.contentStackView = contentStackView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        
        view.clipsToBounds = false
        
        headerIconImageView?.image = UIImage(named: "icon_header_lightning", in: Bundle.library, compatibleWith: nil)
    }
    
    func updateHeight() {
        guard let height = contentHeight else { return }
        modalPresentationManager?.modalPresentationController?.contentHeight = height
    }
    
    @objc private func dismissParent() {
        guard let presentingViewController = presentingViewController else { return }
        
        // fixes the dismiss animation of two modals at once
        if let snapshotView = view.superview?.snapshotView(afterScreenUpdates: false) {
            snapshotView.frame.origin.y = presentingViewController.view.frame.height - snapshotView.frame.height
            presentingViewController.view.addSubview(snapshotView)
        }

        presentingViewController.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension ModalDetailViewController: ContentHeightProviding {
    var contentHeight: CGFloat? {
        let headerImageMargin = (headerIconImageView?.image?.size.height ?? 0) / 2
        let topMargin: CGFloat = 15
        let bottomMargin: CGFloat = 34
        return stackViewContent.height(spacing: contentStackView?.spacing ?? 0) + headerImageMargin + topMargin + bottomMargin
    }
}

extension ModalDetailViewController: ModalTransitionAnimating {
    func animatePresentationTransition() {
        headerIconImageView?.alpha = 1
    }
    
    func animateDismissalTransition() {
        headerIconImageView?.alpha = 0
    }
}

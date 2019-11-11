//
//  Library
//
//  Created by Otto Suess on 17.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

protocol ModalDetailViewControllerDelegate: class {
    func presentError(message: String)
    func childWillDisappear()
}

protocol ParentDismissable {}

extension ParentDismissable where Self: UIViewController {
    func dismissParent() {
        // if presented from QR Code VC, also dismiss the QRCode VC
        if let presentingViewController = presentingViewController,
            presentingViewController.presentingViewController != nil {
            // fixes the dismiss animation of two modals at once
            if let snapshotView = view.superview?.snapshotView(afterScreenUpdates: false) {
                snapshotView.frame.origin.y = presentingViewController.view.frame.height - snapshotView.frame.height
                presentingViewController.view.addSubview(snapshotView)
            }

            presentingViewController.presentingViewController?.dismiss(animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}

class ModalDetailViewController: ModalViewController, ParentDismissable {
    private let closeButton: UIButton = {
        let closeButton = UIButton(type: .custom)
        closeButton.setImage(Asset.iconClose.image, for: .normal)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        return closeButton
    }()

    private let backgroundView: UIView = {
        let backgroundView = UIView(frame: CGRect.zero)
        backgroundView.layer.cornerRadius = Appearance.Constants.modalCornerRadius
        backgroundView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        backgroundView.backgroundColor = UIColor.Zap.background
        return backgroundView
    }()

    let contentStackView: UIStackView = {
        let contentStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        contentStackView.axis = .vertical
        contentStackView.spacing = 14
        return contentStackView
    }()

    let headerIconImageView: UIImageView = {
        let headerIconImageView = UIImageView(image: nil)
        headerIconImageView.alpha = 0
        return headerIconImageView
    }()

    weak var delegate: ModalDetailViewControllerDelegate?

    private func setupLayout(for view: UIView) {
        view.addAutolayoutSubview(backgroundView)
        backgroundView.constrainEdges(to: view)

        view.addAutolayoutSubview(headerIconImageView)
        NSLayoutConstraint.activate([
            headerIconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerIconImageView.centerYAnchor.constraint(equalTo: view.topAnchor)
        ])

        backgroundView.addAutolayoutSubview(contentStackView)
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: headerIconImageView.bottomAnchor, constant: 15),
            contentStackView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20)
        ])

        backgroundView.addAutolayoutSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 45),
            closeButton.heightAnchor.constraint(equalToConstant: 45),
            closeButton.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            closeButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout(for: view)

        view.clipsToBounds = false
    }

    func setHeaderImage(_ image: UIImage?) {
        headerIconImageView.image = image
    }

    func updateHeight() {
        guard let height = contentHeight else { return }
        modalPresentationManager?.modalPresentationController?.contentHeight = height
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.childWillDisappear()
    }

    func addHeadline(_ headline: String) {
        contentStackView.addArrangedElement(.label(text: headline, style: Style.Label.headline.with({ $0.textAlignment = .center })))
        contentStackView.addArrangedElement(.separator)
    }
    
    @objc func close() {
        self.dismissParent()
    }
}

extension ModalDetailViewController: ContentHeightProviding {
    var contentHeight: CGFloat? {
        let headerImageMargin = (headerIconImageView.image?.size.height ?? 0) / 2
        let topMargin: CGFloat = 15
        let bottomMargin: CGFloat = 34

        let width = view.frame.width - 40
        let stackViewHeight = contentStackView.systemLayoutSizeFitting(CGSize(width: width, height: 0), withHorizontalFittingPriority: .defaultHigh, verticalFittingPriority: .defaultLow).height

        return stackViewHeight + headerImageMargin + topMargin + bottomMargin
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

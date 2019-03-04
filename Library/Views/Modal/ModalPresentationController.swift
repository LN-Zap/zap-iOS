//
//  Zap
//
//  Created by Otto Suess on 20.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

protocol ContentHeightProviding {
    var contentHeight: CGFloat? { get }
}

protocol ModalTransitionAnimating {
    func animatePresentationTransition()
    func animateDismissalTransition()
}

final class ModalPresentationManager: NSObject, UIViewControllerTransitioningDelegate {
    var modalPresentationController: ModalPresentationController?

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let modalPresentationController = ModalPresentationController(presentedViewController: presented, presenting: presenting)
        self.modalPresentationController = modalPresentationController
        return modalPresentationController
    }
}

final class ModalPresentationController: UIPresentationController {
    var dimmingView: UIView?
    var contentHeight: CGFloat? {
        didSet {
            presentedView?.setNeedsUpdateConstraints()
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let frame = self?.frameOfPresentedViewInContainerView else { return }
                self?.presentedView?.frame = frame
                self?.presentedView?.layoutIfNeeded()
            }
        }
    }
    private var bottomOffset: CGFloat = 0

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        setupDimmingView()
        setupKeyboardNotifications()
    }

    private func setupDimmingView() {
        guard let frame = UIApplication.shared.keyWindow?.frame else { return }
        dimmingView = UIView(frame: frame)
        dimmingView?.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped(tapRecognizer:)))
        dimmingView?.addGestureRecognizer(tapRecognizer)
    }

    @objc private func dimmingViewTapped(tapRecognizer: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true, completion: nil)
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = self.containerView,
            let dimmingView = dimmingView else { return }

        dimmingView.frame = containerView.bounds
        dimmingView.alpha = 0.0

        containerView.insertSubview(dimmingView, at: 0)

        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView?.alpha = 1.0
            (self.presentedViewController as? ModalTransitionAnimating)?.animatePresentationTransition()
        }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView?.alpha = 0.0
            (self.presentedViewController as? ModalTransitionAnimating)?.animateDismissalTransition()
        }, completion: nil)
    }

    override func containerViewWillLayoutSubviews() {
        guard
            let containerView = containerView,
            let dimmingView = dimmingView
            else { return }

        dimmingView.frame = containerView.bounds
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        let height = contentHeight ?? floor(parentSize.height * 0.75)
        return CGSize(width: parentSize.width, height: height)
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let parentSize = containerView?.bounds.size else { return CGRect.zero }

        let presentedSize: CGSize

        if contentHeight == nil,
            let detailViewController = presentedViewController as? ContentHeightProviding,
            let contentHeight = detailViewController.contentHeight {
            presentedSize = CGSize(width: parentSize.width, height: contentHeight)
        } else {
            presentedSize = size(forChildContentContainer: presentedViewController, withParentContainerSize: parentSize)
        }

        return CGRect(
            origin: CGPoint(
                x: (parentSize.width - presentedSize.width) / 2,
                y: (parentSize.height - presentedSize.height - bottomOffset)
            ),
            size: presentedSize
        )
    }

    // MARK: - Keyboard

    func setupKeyboardNotifications() {
        NotificationCenter.default.reactive.notification(name: UIResponder.keyboardWillHideNotification)
            .observeNext { [weak self] _ in
                self?.updateKeyboardHeight(to: 0)
            }
            .dispose(in: reactive.bag)

        NotificationCenter.default.reactive.notification(name: UIResponder.keyboardWillShowNotification)
            .observeNext { [weak self] notification in
                guard
                    let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                    else { return }
                self?.updateKeyboardHeight(to: keyboardFrame.height)
            }
            .dispose(in: reactive.bag)
    }

    private func updateKeyboardHeight(to height: CGFloat) {
        bottomOffset = height

        presentedView?.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let frame = self?.frameOfPresentedViewInContainerView else { return }
            self?.presentedView?.frame = frame
            self?.presentedView?.layoutIfNeeded()
        }
    }

}

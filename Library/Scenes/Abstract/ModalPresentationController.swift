//
//  Zap
//
//  Created by Otto Suess on 20.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

final class ModalPresentationManager: NSObject, UIViewControllerTransitioningDelegate {
    let size: CGSize?
    
    init(size: CGSize? = nil) {
        self.size = size
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(presentedViewController: presented, presenting: presenting, size: size)
    }
}

final class ModalPresentationController: UIPresentationController {
    var dimmingView: UIView?
    var size: CGSize?
    var customFrame: CGRect?
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, size: CGSize?) {
        self.size = size
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        setupDimmingView()
    }
    
    private func setupDimmingView() {
        guard let frame = UIApplication.shared.keyWindow?.frame else { return }
        dimmingView = UIView(frame: frame)
        dimmingView?.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped(tapRecognizer:)))
        dimmingView?.addGestureRecognizer(tapRecognizer)
    }
    
    private func applyCornerRoundingMask(to view: UIView) {
        let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [.topRight, .topLeft], cornerRadii: CGSize(width: 20, height: 20))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        view.layer.mask = maskLayer
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
        
        let parentSize = containerView.bounds.size
        let presentedSize = size(forChildContentContainer: presentedViewController, withParentContainerSize: parentSize)
        if parentSize != presentedSize {
            presentedViewController.view.clipsToBounds = true
        }
        
        applyCornerRoundingMask(to: presentedViewController.view)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView?.alpha = 1.0
        }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView?.alpha = 0.0
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
        return size ?? CGSize(width: parentSize.width, height: floor(parentSize.height * 0.75))
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        if let customFrame = customFrame {
            return customFrame
        }
        
        guard let parentSize = containerView?.bounds.size else { return CGRect.zero }

        let presentedSize = size(forChildContentContainer: presentedViewController, withParentContainerSize: parentSize)

        var presentedViewFrame = CGRect.zero
        presentedViewFrame.size = presentedSize
        presentedViewFrame.origin = CGPoint(
            x: (parentSize.width - presentedSize.width) / 2,
            y: (parentSize.height - presentedSize.height))

        return presentedViewFrame
    }
}

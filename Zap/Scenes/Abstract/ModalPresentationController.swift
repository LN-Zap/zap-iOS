//
//  Zap
//
//  Created by Otto Suess on 20.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

final class ModalPresentationManager: NSObject, UIViewControllerTransitioningDelegate {
    let size: CGSize?
    
    var presentationController: ModalPresentationController?
    
    init(size: CGSize? = nil) {
        self.size = size
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        presentationController = ModalPresentationController(presentedViewController: presented, presenting: presenting, size: size)
        return presentationController
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TransitionPresentationAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TransitionDismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let interactionController = presentationController?.dismissInteractionController else { return nil }
        return interactionController.isInteractiveDismissal ? interactionController : nil
    }
}

final class ModalPresentationController: UIPresentationController {
    var dimmingView: UIView?
    var size: CGSize?
    var customFrame: CGRect?
    var dismissInteractionController: InteractiveTransitionDismissAnimator?
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, size: CGSize?) {
        self.size = size
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        setupDimmingView()
    }
    
    func animateFrame(to frame: CGRect) {
        guard let presentedView = presentedView else { return }
        size = frame.size
        customFrame = frame
    
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: { [presentedViewController] in
            presentedView.frame = frame
            
            if let naivgationController = presentedViewController as? UINavigationController {
                naivgationController.setNeedsStatusBarAppearanceUpdate()
                naivgationController.isNavigationBarHidden = true
                naivgationController.isNavigationBarHidden = false
            }
        }, completion: nil)
    }
    
    func setupDimmingView() {
        guard let frame = UIApplication.shared.keyWindow?.frame else { return }
        dimmingView = UIView(frame: frame)
        dimmingView?.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped(tapRecognizer:)))
        dimmingView?.addGestureRecognizer(tapRecognizer)
    }
    
    @objc
    func dimmingViewTapped(tapRecognizer: UITapGestureRecognizer) {
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
        return CGSize(width: parentSize.width, height: floor(parentSize.height * 0.75))
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
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        guard let view = presentedViewController.view else { return }
        dismissInteractionController = InteractiveTransitionDismissAnimator(view: view, viewController: presentedViewController)
    }
}

private func verticalTranslation(for viewController: UIViewController) -> CGFloat {
    let viewHeight = viewController.view.bounds.height
    let windowHeight = UIApplication.shared.keyWindow?.bounds.height ?? 0
    return (windowHeight + viewHeight) / 2
}

final class TransitionPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else { return }
        let containerView = transitionContext.containerView
        
        let animationDuration = transitionDuration(using: transitionContext)
        
        toViewController.view.transform = CGAffineTransform(translationX: 0, y: verticalTranslation(for: toViewController))
        
        containerView.addSubview(toViewController.view)
        
        UIView.animate(withDuration: animationDuration, animations: {
            toViewController.view.transform = CGAffineTransform.identity
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }
}

final class TransitionDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else { return }
        
        let animationDuration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: animationDuration, animations: {
            fromViewController.view.transform = CGAffineTransform(translationX: 0, y: verticalTranslation(for: fromViewController))
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

final class InteractiveTransitionDismissAnimator: UIPercentDrivenInteractiveTransition {
    var isInteractiveDismissal = false
    let gestureRecognizer: UIPanGestureRecognizer
    weak var viewController: UIViewController?
    
    init(view: UIView, viewController: UIViewController) {
        gestureRecognizer = UIPanGestureRecognizer()
        
        self.viewController = viewController
        
        super.init()
        
        view.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.addTarget(self, action: #selector(didPan(sender:)))
    }
    
    @objc
    func didPan(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            isInteractiveDismissal = true
            viewController?.dismiss(animated: true, completion: nil)
        case .changed:
            update(percentCompleteForTranslation(translation: sender.translation(in: sender.view)))
        case .ended:
            if percentComplete > 0.33 || sender.velocity(in: sender.view).y > 1000 {
                finish()
            } else {
                cancel()
            }
            isInteractiveDismissal = false
        case .cancelled:
            cancel()
            isInteractiveDismissal = false
        default:
            return
        }
    }
    
    private func percentCompleteForTranslation(translation: CGPoint) -> CGFloat {
        guard let viewController = viewController else { return 0 }
        let panDistance = max(0, translation.y)
        return panDistance / verticalTranslation(for: viewController)
    }
}

//
//  Library
//
//  Created by 0 on 05.04.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

final class LoadingAnimationView: UIView {
    private enum LoadingState {
        case running
        case runningFinal
        case stopped
    }

    private let lineWidth: CGFloat = 1
    private let timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0, 0.2, 1.0)
    private let animationDuration: TimeInterval = 1

    private var loadingState = LoadingState.running
    private var circle: CAShapeLayer?
    private var imageView: UIImageView?

    private var afterCompletion: (() -> Void)?

    private var loadingImage: ImageAsset

    init(frame: CGRect, loadingImage: ImageAsset) {
        self.loadingImage = loadingImage
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        let imageView = UIImageView(image: loadingImage.image)
        imageView.tintColor = UIColor.white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        self.imageView = imageView
    }

    func circle(size: CGSize, color: UIColor) -> CAShapeLayer {
        let layer: CAShapeLayer = CAShapeLayer()
        let path: UIBezierPath = UIBezierPath()

        path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                    radius: size.width / 2,
                    startAngle: -(.pi / 2),
                    endAngle: .pi + .pi / 2,
                    clockwise: true)
        layer.fillColor = nil
        layer.strokeColor = color.cgColor
        layer.lineWidth = lineWidth

        layer.backgroundColor = nil
        layer.path = path.cgPath
        layer.frame = CGRect(origin: .zero, size: size)

        return layer
    }

    func startAnimating() {
        let beginTime = animationDuration / 2

        let strokeEndAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
        strokeEndAnimation.duration = animationDuration
        strokeEndAnimation.timingFunction = timingFunction
        strokeEndAnimation.fromValue = 0
        strokeEndAnimation.toValue = 1

        let strokeStartAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeStart))
        strokeStartAnimation.duration = animationDuration
        strokeStartAnimation.timingFunction = timingFunction
        strokeStartAnimation.fromValue = 0
        strokeStartAnimation.toValue = 1
        strokeStartAnimation.beginTime = animationDuration / 2

        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [strokeEndAnimation, strokeStartAnimation]
        groupAnimation.duration = animationDuration + beginTime
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = .forwards
        groupAnimation.delegate = self

        loadingState = .running

        if circle == nil {
            let circle = self.circle(size: bounds.size, color: UIColor.Zap.superGreen)
            circle.frame = bounds
            layer.addSublayer(circle)
            self.circle = circle
        }

        circle?.add(groupAnimation, forKey: "animation")
    }

    private func startFinalAnimation() {
        let strokeEndAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
        strokeEndAnimation.duration = animationDuration
        strokeEndAnimation.timingFunction = timingFunction
        strokeEndAnimation.fromValue = 0
        strokeEndAnimation.toValue = 1
        strokeEndAnimation.isRemovedOnCompletion = true
        strokeEndAnimation.fillMode = .forwards
        strokeEndAnimation.delegate = self

        loadingState = .stopped
        circle?.add(strokeEndAnimation, forKey: "animation")

        transitionImage()
    }

    private func transitionImage() {
        guard let imageView = imageView else { return }
        let duration = animationDuration / 2
        UIView.transition(with: imageView, duration: duration, options: .transitionCrossDissolve, animations: {
            imageView.image = nil
        }, completion: { [weak self] _ in
            self?.afterCompletion?()

            UIView.transition(with: imageView, duration: duration, options: .transitionCrossDissolve, animations: {
                imageView.image = Asset.loadingCheck.image
                imageView.tintColor = UIColor.Zap.superGreen
            })
        })
    }

    func stopAnimation(afterCompletion: @escaping () -> Void) {
        self.afterCompletion = afterCompletion
        loadingState = .runningFinal
    }
}

extension LoadingAnimationView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        switch loadingState {
        case .running:
            startAnimating()
        case .runningFinal:
            startFinalAnimation()
        case .stopped:
            break
        }
    }
}

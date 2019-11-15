//
//  Library
//
//  Created by 0 on 14.11.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import ReactiveKit
import SwiftBTC

final class BalanceDetailView: UIView {
    @IBOutlet private weak var detailHandleView: ArrowHandleView!
    @IBOutlet private weak var segmentStackView: UIStackView!
    @IBOutlet private weak var circleGraphView: CircleGraphView!
    @IBOutlet private weak var segmentBackground: UIView!

    private var dragStartPosition: CGFloat = 0
    private var detailMaxOffset: CGFloat {
        return -(bounds.height - 45) - 60
    }
    
    private dynamic var progress: CGFloat = 0 {
        didSet {
            detailHandleView.progress = progress
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        segmentBackground.layer.cornerRadius = Constants.buttonCornerRadius

        circleGraphView.arcWidth = 6
        circleGraphView.emptyColor = UIColor.Zap.deepSeaBlue
    }

    private func setup() {
        let views = Bundle.library.loadNibNamed("BalanceDetailView", owner: self, options: nil)
        guard let content = views?.first as? UIView else { return }

        addAutolayoutSubview(content)

        content.backgroundColor = UIColor.Zap.background
        
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: bottomAnchor),
            content.leadingAnchor.constraint(equalTo: leadingAnchor),
            content.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func setup(viewModel: BalanceDetailViewModel) {
        segmentStackView.clear()
        for segment in viewModel.balanceSegments {
            segmentStackView.addSegment(segment.segment, color: segment.segment.color, title: segment.segment.localized, amount: segment.amount)
        }
        
        viewModel.circleGraphSegments
            .observeOn(DispatchQueue.main)
            .observeNext { [circleGraphView] in
                circleGraphView?.segments = $0
            }
            .dispose(in: reactive.bag)
    }

    @IBAction private func didPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: superview)
        let maxOffset = detailMaxOffset

        let yTranslation: CGFloat
        let newOffset = dragStartPosition + translation.y

        if newOffset < maxOffset {
            let additionalOffset = (newOffset - detailMaxOffset)
            yTranslation = maxOffset - pow(abs(additionalOffset), 0.85)
        } else {
            yTranslation = min(0, newOffset)
        }

        switch sender.state {
        case .possible:
            break
        case .began:
            dragStartPosition = transform.ty
        case .changed:
            transform = CGAffineTransform(translationX: 0, y: yTranslation)
            progress = max(yTranslation, maxOffset) / maxOffset

        case .ended, .cancelled, .failed:
            let velocity = sender.velocity(in: superview).y
            let triggerVelocity: CGFloat = 600

            if (yTranslation < maxOffset / 2 || velocity < -triggerVelocity) && velocity < triggerVelocity {
                animateDetail(expanded: true)
            } else {
                animateDetail(expanded: false)
            }
        @unknown default:
            break
        }
    }
    
    func updatePosition() {
        if UserDefaults.Keys.walletDetailExpanded.get(defaultValue: false) {
            transform = CGAffineTransform(translationX: 0, y: detailMaxOffset)
            progress = 1
        } else {
            transform = .identity
            progress = 0
        }
    }
    
    @IBAction private func toggleDetailState() {
        if transform == .identity {
            animateDetail(expanded: true)
        } else if transform.ty == detailMaxOffset {
            animateDetail(expanded: false)
        }
    }
    
    private func animateDetail(expanded: Bool) {
        let transform: CGAffineTransform
        let detailHandleViewProgress: CGFloat
        
        if expanded {
            transform = CGAffineTransform(translationX: 0, y: detailMaxOffset)
            detailHandleViewProgress = 1
            
            UserDefaults.Keys.walletDetailExpanded.set(true)
        } else {
            // bounce back
            transform = .identity
            detailHandleViewProgress = 0
            
            UserDefaults.Keys.walletDetailExpanded.set(false)
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.25, options: [], animations: { [weak self] in
            self?.transform = transform
            self?.progress = detailHandleViewProgress
        }, completion: nil)
    }
}

private extension UIStackView {
    func addSegment(_ segment: Segment, color: UIColor, title: String, amount: Signal<Satoshi, Never>) {
        let circleView = CircleView(frame: .zero)
        circleView.backgroundColor = .clear
        circleView.color = color

        let titleLabel = UILabel(frame: .zero)
        Style.Label.subHeadline.with({ $0.font = $0.font.withSize(17) }).apply(to: titleLabel)
        titleLabel.text = title

        let amountLabel = UILabel(frame: .zero)
        Style.Label.headline.apply(to: amountLabel)
        amountLabel.textAlignment = .right
        amount
            .bind(to: amountLabel.reactive.text, currency: Settings.shared.primaryCurrency)
            .dispose(in: reactive.bag)

        let horizontalStackView = UIStackView(arrangedSubviews: [circleView, titleLabel, amountLabel])
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 10

        NSLayoutConstraint.activate([
            circleView.widthAnchor.constraint(equalToConstant: 8)
        ])

        addArrangedSubview(horizontalStackView)

        if segment == .pending {
            amount
                .map { $0 <= 0 }
                .observeOn(DispatchQueue.main)
                .observeNext {
                    horizontalStackView.isHidden = $0
                }
                .dispose(in: reactive.bag)
        }
    }
}

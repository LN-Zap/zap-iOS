//
//  Library
//
//  Created by 0 on 15.11.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

final class BalanceSkeletonView: UIView {
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        
        let topView = SkeletonView()
        let topContainer = UIView()
        topContainer.addAutolayoutSubview(topView)
        
        let middleView = SkeletonView()
        
        let bottomView = SkeletonView()
        let bottomContainer = UIView()
        bottomContainer.addAutolayoutSubview(bottomView)

        let stackView = UIStackView(arrangedSubviews: [
            topContainer,
            middleView,
            bottomContainer
        ])
        stackView.spacing = 10
        stackView.axis = .vertical
        
        NSLayoutConstraint.activate([
            topView.heightAnchor.constraint(equalToConstant: 24),
            topView.widthAnchor.constraint(equalToConstant: 130),
            topView.centerXAnchor.constraint(equalTo: topContainer.centerXAnchor),
            topView.topAnchor.constraint(equalTo: topContainer.topAnchor),
            topView.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor),
            middleView.heightAnchor.constraint(equalToConstant: 55),
            middleView.widthAnchor.constraint(equalToConstant: 250),
            bottomView.heightAnchor.constraint(equalToConstant: 24),
            bottomView.widthAnchor.constraint(equalToConstant: 130),
            bottomView.centerXAnchor.constraint(equalTo: bottomContainer.centerXAnchor),
            bottomView.topAnchor.constraint(equalTo: bottomContainer.topAnchor),
            bottomView.bottomAnchor.constraint(equalTo: bottomContainer.bottomAnchor)
        ])
        
        addAutolayoutSubview(stackView)
        stackView.constrainEdges(to: self)
    }
}

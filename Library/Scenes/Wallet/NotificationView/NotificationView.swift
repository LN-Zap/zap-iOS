//
//  Library
//
//  Created by 0 on 28.10.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

final class NotificationView: UIView {
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var actionButton: UIButton!
    
    var notificationViewModel: NotificationViewModel? {
        didSet {
            updateNotification()
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
        
        backgroundView.layer.cornerRadius = Constants.buttonCornerRadius
        backgroundView.backgroundColor = UIColor.Zap.seaBlue
        
        Style.Label.body.apply(to: messageLabel)
    }
    
    private func setup() {
        let views = Bundle.library.loadNibNamed("NotificationView", owner: self, options: nil)
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
    
    private func updateNotification() {
        messageLabel.text = notificationViewModel?.message
        actionButton.setTitle(notificationViewModel?.actionTitle, for: .normal)
    }
    
    @IBAction private func notificationTapped(_ sender: Any) {
        notificationViewModel?.action()
    }
}

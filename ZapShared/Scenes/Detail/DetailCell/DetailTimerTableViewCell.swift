//
//  Zap
//
//  Created by Otto Suess on 19.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class DetailTimerTableViewCell: UITableViewCell {
    struct Info {
        let title: String
        let date: Date
    }

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var timerLabel: UILabel!
    
    var info: Info? {
        didSet {
            guard let info = info else { return }
            
            titleLabel.text = info.title.appending(":")
            
            updateTimerLabel()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.updateTimerLabel()
            }
        }
    }
    
    private var timer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        Style.label.apply(to: titleLabel, timerLabel)
        titleLabel.font = DetailCellType.titleFont
        timerLabel.font = DetailCellType.dataFont
    }
    
    private func updateTimerLabel() {
        guard
            let info = info,
            let expiry = formatedTime(for: info.date)
            else { return }
        timerLabel.text = expiry        
    }
    
    private func formatedTime(for date: Date) -> String? {
        let currentDate = Date()
        guard date >= currentDate else { return "scene.transaction_detail.qr_code.expired_label".localized }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.maximumUnitCount = 3
        return formatter.string(from: currentDate, to: date)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        timer?.invalidate()
    }
}

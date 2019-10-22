//
//  Library
//
//  Created by 0 on 13.09.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import ReactiveKit

final class SyncView: UIView {
    @IBOutlet private weak var syncTitleLabel: UILabel!
    @IBOutlet private weak var syncProgressLabel: UILabel!
    @IBOutlet private weak var syncProgressView: UIProgressView!

    var syncViewModel: SyncViewModel? {
        didSet {
            setupSyncView()
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

    private func setup() {
        let views = Bundle.library.loadNibNamed("SyncView", owner: self, options: nil)
        guard let content = views?.first as? UIView else { return }

        addAutolayoutSubview(content)
        content.backgroundColor = UIColor.Zap.seaBlue

        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: bottomAnchor),
            content.leadingAnchor.constraint(equalTo: leadingAnchor),
            content.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func setupSyncView() {
        guard let syncViewModel = syncViewModel else { return }

        syncViewModel.isSyncing
            .debounce(interval: 2)
            .observeOn(DispatchQueue.main)
            .observeNext { [weak self] isSyncing in
                UIView.animate(withDuration: 0.25) {
                    self?.isHidden = !isSyncing
                }
            }
            .dispose(in: reactive.bag)

        syncProgressView.trackTintColor = UIColor.Zap.deepSeaBlue

        syncViewModel.percentSignal
            .map { Float($0) }
            .bind(to: syncProgressView.reactive.progress)
            .dispose(in: reactive.bag)

        syncViewModel.percentSignal
            .map { "\(Int($0 * 100))%" }
            .bind(to: syncProgressLabel.reactive.text)
            .dispose(in: reactive.bag)

        syncTitleLabel.text = L10n.Scene.Sync.descriptionLabel

        backgroundColor = UIColor.Zap.seaBlue

        Style.Label.body.apply(to: syncTitleLabel, syncProgressLabel)
    }
}

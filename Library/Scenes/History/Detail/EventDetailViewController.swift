//
//  Library
//
//  Created by Otto Suess on 22.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Lightning
import SwiftBTC

final class EventDetailViewController: ModalDetailViewController {
    let viewModel: EventDetailViewModel
    let presentBlockExplorer: (String, BlockExplorer.CodeType) -> Void

    init(event: HistoryEventType, presentBlockExplorer: @escaping (String, BlockExplorer.CodeType) -> Void) {
        viewModel = EventDetailViewModel(event: event)
        self.presentBlockExplorer = presentBlockExplorer
        
        super.init(nibName: nil, bundle: nil)
        
        viewModel.blockExplorerButtonTapped.observeNext { [weak self] blockExplorerItem in
            guard let self = self else { return }
            self.dismiss(animated: true) {
                self.presentBlockExplorer(blockExplorerItem.code, blockExplorerItem.type)
            }
        }.dispose(in: reactive.bag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupEvent()
    }

    private func setupEvent() {
        let configuration = viewModel.detailConfiguration()
        contentStackView.set(elements: configuration)
    }
}

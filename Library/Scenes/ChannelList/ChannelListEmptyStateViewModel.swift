//
//  Library
//
//  Created by 0 on 31.07.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Bond
import Foundation

final class ChannelListEmptyStateViewModel: EmptyStateViewModel {
    let title = L10n.Scene.Channels.EmptyState.title
    let message = L10n.Scene.Channels.EmptyState.message
    let buttonTitle = L10n.Scene.Channels.EmptyState.buttonTitle
    let image = Emoji.image(emoji: "⚡️")
    let buttonEnabled = Observable(true)

    let openButtonTapped: () -> Void

    init(openButtonTapped: @escaping () -> Void) {
        self.openButtonTapped = openButtonTapped
    }

    func actionButtonTapped() {
        openButtonTapped()
    }
}

//
//  Library
//
//  Created by Otto Suess on 18.10.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftLnd

final class NodeURIQRCodeViewModel: QRCodeDetailViewModel {
    let title: String
    let uriString: String
    let qrCodeString: String
    let detailConfiguration: [StackViewElement]
    
    init?(info: Info) {
        guard let uri = info.uris.first else { return nil }
        
        self.title = L10n.Scene.NodeUri.title
        self.uriString = uri.absoluteString
        self.qrCodeString = uri.absoluteString
        
        let tableFontStyle = Style.Label.footnote
        let tableLabelSpacing: CGFloat = 0
        var detailConfiguration = [StackViewElement]()
        
        if !info.alias.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            detailConfiguration.append(contentsOf: [
                .verticalStackView(content: [
                    .label(text: L10n.Scene.NodeUri.aliasLabel + ":", style: tableFontStyle),
                    .label(text: info.alias, style: tableFontStyle)
                ], spacing: tableLabelSpacing),
                .separator
            ])
        }
        
        detailConfiguration.append(.verticalStackView(content: [
            .label(text: L10n.Scene.NodeUri.uriLabel + ":", style: tableFontStyle),
            .label(text: uri.absoluteString, style: tableFontStyle)
        ], spacing: tableLabelSpacing))
        
        self.detailConfiguration = detailConfiguration

    }
}

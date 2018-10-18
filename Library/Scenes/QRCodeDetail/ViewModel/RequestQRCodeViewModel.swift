//
//  Library
//
//  Created by Otto Suess on 18.10.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftBTC

final class RequestQRCodeViewModel: QRCodeDetailViewModel {
    let title = "scene.qr_code_detail.title".localized
    let uriString: String
    let qrCodeString: String
    let detailConfiguration: [StackViewElement]
    
    init(paymentURI: PaymentURI) {
        uriString = paymentURI.uriString
        qrCodeString = paymentURI.isCaseSensitive ? paymentURI.uriString : paymentURI.uriString.uppercased()
        
        let tableFontStyle = Style.Label.footnote
        let tableLabelSpacing: CGFloat = 0
        var detailConfiguration = [StackViewElement]()
        
        if let amount = paymentURI.amount, amount != 0 {
            detailConfiguration.append(contentsOf: [
                .verticalStackView(content: [
                    .label(text: "scene.transaction_detail.amount_label".localized + ":", style: tableFontStyle),
                    .amountLabel(amount: amount, style: tableFontStyle)
                ], spacing: tableLabelSpacing),
                .separator
            ])
        }
        
        if let memo = paymentURI.memo, !memo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            detailConfiguration.append(contentsOf: [
                .verticalStackView(content: [
                    .label(text: "scene.transaction_detail.memo_label".localized + ":", style: tableFontStyle),
                    .label(text: memo, style: tableFontStyle)
                ], spacing: tableLabelSpacing),
                .separator
            ])
        }
        
        detailConfiguration.append(.verticalStackView(content: [
            .label(text: "scene.transaction_detail.address_label".localized + ":", style: tableFontStyle),
            .label(text: paymentURI.address, style: tableFontStyle)
        ], spacing: tableLabelSpacing))
        
        self.detailConfiguration = detailConfiguration
    }
}

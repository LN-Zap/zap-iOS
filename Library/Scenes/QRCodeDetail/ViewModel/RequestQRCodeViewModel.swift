//
//  Library
//
//  Created by Otto Suess on 18.10.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftBTC

final class RequestQRCodeViewModel: QRCodeDetailViewModel {
    let title = L10n.Scene.QrCodeDetail.title
    let uriString: String
    let qrCodeString: String
    let detailConfiguration: [StackViewElement]

    init(paymentURI: PaymentURI) {
        uriString = paymentURI.address
        qrCodeString = paymentURI.isCaseSensitive ? paymentURI.uriString : paymentURI.uriString.uppercased()

        let tableFontStyle = Style.Label.footnote
        let tableLabelSpacing: CGFloat = 0
        var detailConfiguration = [StackViewElement]()

        if let amount = paymentURI.amount, amount != 0 {
            detailConfiguration.append(contentsOf: [
                .verticalStackView(content: [
                    .label(text: L10n.Scene.TransactionDetail.amountLabel + ":", style: tableFontStyle),
                    .amountLabel(amount: amount, style: tableFontStyle)
                ], spacing: tableLabelSpacing),
                .separator
            ])
        }

        if let memo = paymentURI.memo, !memo.trimAllWhitespacesAndNewlines().isEmpty {
            detailConfiguration.append(contentsOf: [
                .verticalStackView(content: [
                    .label(text: L10n.Scene.TransactionDetail.memoLabel + ":", style: tableFontStyle),
                    .label(text: memo, style: tableFontStyle)
                ], spacing: tableLabelSpacing),
                .separator
            ])
        }

        detailConfiguration.append(.verticalStackView(content: [
            .label(text: L10n.Scene.TransactionDetail.addressLabel + ":", style: tableFontStyle),
            .label(text: paymentURI.address, style: tableFontStyle)
        ], spacing: tableLabelSpacing))

        self.detailConfiguration = detailConfiguration
    }
}

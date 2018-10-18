//
//  Zap
//
//  Created by Otto Suess on 07.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

protocol QRCodeDetailViewModel {
    var title: String { get }
    var uriString: String { get }
    var qrCodeString: String { get }
    var detailConfiguration: [StackViewElement] { get }
}

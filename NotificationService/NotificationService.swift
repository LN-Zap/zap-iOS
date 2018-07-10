//
//  NotificationService
//
//  Created by Otto Suess on 10.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    struct EncodedBody: Decodable {
        let message: String
        let values: [String]
        
        enum CodingKeys: String, CodingKey {
            case message = "m"
            case values = "v"
        }
    }
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            
            do {
                guard
                    let encryptedBase64 = bestAttemptContent.userInfo["encrypted"] as? String,
                    let data = Data(base64Encoded: encryptedBase64)
                    else { return }
                
                let decrypted = try NotificationKeyPair.manager.decrypt(data, hash: .sha256)
                let json = try JSONDecoder().decode(EncodedBody.self, from: decrypted)

                bestAttemptContent.body = String(format: NSLocalizedString(json.message, comment: ""), arguments: json.values)
            } catch {
                bestAttemptContent.body = "\(error.localizedDescription)"
            }
            
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}

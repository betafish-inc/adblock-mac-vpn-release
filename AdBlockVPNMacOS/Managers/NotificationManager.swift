//    AdBlock VPN
//    Copyright © 2020-present Adblock, Inc. All rights reserved.
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
import UserNotifications

enum NotificationType: String {
    case connection
    case error
}

class NotificationManager {
    let center = UNUserNotificationCenter.current()
    var allowed = false
    var shouldShow = true
    
    init() {
        center.getNotificationSettings { [weak self] settings in
            if settings.authorizationStatus == .authorized {
                self?.allowed = true
            }
        }
    }
    
    func requestAuth() {
        center.requestAuthorization(options: [.alert]) { [weak self] (granted, _) in
            if granted {
                self?.allowed = true
            }
        }
    }
    
    func sendNotification(type: NotificationType, message: String, imageName: String?) {
        if !shouldShow { return }
        
        let content = UNMutableNotificationContent()
        content.body = message
        if let image = imageName, !image.isEmpty, let url = Bundle.main.url(forResource: image, withExtension: "png") {
            if let attachment = try? UNNotificationAttachment(identifier: "ABNotificationImage", url: url, options: nil) {
                content.attachments = [attachment]
            }
        }
        
        let request = UNNotificationRequest(identifier: "ABNotification_\(type.rawValue)", content: content, trigger: nil)
        center.add(request)
    }
}

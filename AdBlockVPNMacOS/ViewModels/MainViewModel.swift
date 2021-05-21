//    AdBlock VPN
//    Copyright © 2020-2021 Betafish Inc. All rights reserved.
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
import AppKit
import SwiftyBeaver

class MainViewModel: ObservableObject {
    private var authManager: AuthManager
    private var vpnManager: VPNManager
    private var errorManager: ErrorManager
    private var notificationManager: NotificationManager
    @Published var vpnAllowed: Bool?
    @Published var restartConnection = false
    @Published var providerAuthChecked = false
    
    init(authManager: AuthManager, vpnManager: VPNManager, errorManager: ErrorManager, notificationManager: NotificationManager) {
        self.authManager = authManager
        self.vpnManager = vpnManager
        self.errorManager = errorManager
        self.notificationManager = notificationManager
    }
    
    func checkState() {
        SwiftyBeaver.verbose("Check state")
        checkLoggedIn()
    }
    
    func showErrorNotification() {
        notificationManager.sendNotification(type: .error, message: errorManager.getFullNotificationMessage(), imageName: "Alert")
    }
    
    func checkForError() {
        vpnManager.initializeProviderManager { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.sendAuthInquiry()
            strongSelf.errorManager.checkError = false
        }
    }
    
    private func checkLoggedIn() {
        vpnManager.initializeProviderManager { [weak self] vpnProfileAllowed in
            guard let strongSelf = self else { return }
            strongSelf.vpnAllowed = vpnProfileAllowed
            strongSelf.sendAuthInquiry {
                strongSelf.providerAuthChecked = true
            }
        }
    }
    
    private func sendAuthInquiry(callback: (() -> Void)? = nil) {
        vpnManager.sendMessageToProvider(message: "authInquiry") { [weak self] message in
            guard let strongSelf = self else { return }
            var errorSet = false
            if let response = message, !response.isEmpty {
                let messageArray = response.split(separator: " ")
                if messageArray.count == 2 {
                    strongSelf.restartConnection = Int(messageArray[0]) == 1
                    errorSet = Int(messageArray[1]) == 1
                } else if messageArray.count == 4 {
                    strongSelf.restartConnection = Int(messageArray[0]) == 1
                    let messageToken = String(messageArray[1])
                    let messageDate = Double(messageArray[2]) ?? 0
                    strongSelf.checkAuthResponse(tokenString: messageToken, dateNumber: messageDate)
                    errorSet = Int(messageArray[3]) == 1
                }
            } else if message == nil {
                SwiftyBeaver.debug("error sending auth inquiry to provider")
            }
            if errorSet {
                strongSelf.sendErrorCheck(callback: callback)
            } else {
                callback?()
            }
        }
    }
    
    private func sendErrorCheck(callback: (() -> Void)? = nil) {
        vpnManager.sendMessageToProvider(message: "errorCheck") { [weak self] message in
            guard let strongSelf = self else { return }
            if let response = message, !response.isEmpty {
                strongSelf.errorManager.setFromAsteriskDelimitedString(asteriskString: response)
            } else if message == nil {
                SwiftyBeaver.debug("error sending error check to provider")
            }
            callback?()
        }
    }
    
    private func checkAuthResponse(tokenString: String, dateNumber: Double) {
        let date = Date(timeIntervalSince1970: TimeInterval(dateNumber))
        
        if date > authManager.token.creationDate {
            authManager.token = TokenInfo(accessToken: "", tokenType: "", expiresIn: 0, refreshToken: tokenString, creationDate: date)
        }
    }
}

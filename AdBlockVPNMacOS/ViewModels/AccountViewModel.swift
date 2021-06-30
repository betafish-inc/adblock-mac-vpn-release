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
import AppKit
import SwiftyBeaver

class AccountViewModel: ObservableObject {
    private var vpnManager: VPNManager
    private var authManager: AuthManager
    
    init(vpnManager: VPNManager, authManager: AuthManager) {
        self.vpnManager = vpnManager
        self.authManager = authManager
    }
    
    func logOut() {
        authManager.logOut()
        vpnManager.sendMessageToProvider(message: "loggedOut") { result in
            SwiftyBeaver.verbose("logged out provider result: \(result ?? "error")")
        }
    }
    
    func openAccountManagement() {
        // TODO: replace with magic link to be logged in automatically if logged in in the app
        if let url = URL(string: Constants.accountsURL) {
            NSWorkspace.shared.open(url)
        }
    }
}

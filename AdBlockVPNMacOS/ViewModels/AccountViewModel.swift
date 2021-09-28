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

import Alamofire
import AppKit
import Foundation
import SwiftyBeaver

class AccountViewModel: ObservableObject {
    private var vpnManager: VPNManager
    private var authManager: AuthManager
    @Published var isRequestingMagicLink = false

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

    /// Requests and opens a single use magic link that automatically logs into the account management page.
    func openAccountManagement() {
        isRequestingMagicLink = true
        AF.request(Constants.accountsMagicLoginURL,
                   method: .get,
                   headers: [.authorization(bearerToken: authManager.token.access_token)])
            .responseDecodable(of: MagicLink.self) { response in
                switch response.result {
                case .success(let response):
                    guard let urlString = response.url,
                          let url = URL(string: urlString) else {
                        // API request has failed to provide a valid URL
                        SwiftyBeaver.warning("Magic Link generation failed with error: \(response.err ?? "Undefined Error"))")
                        self.openAccountManagementLogin()
                        return
                    }
                    SwiftyBeaver.verbose("Magic link generated - Opening URL")
                    NSWorkspace.shared.open(url)
                case .failure(let error):
                    // Network request has failed with an error
                    SwiftyBeaver.warning("Magic Link generation failed with error: \(error)")
                    self.openAccountManagementLogin()
                }
                self.isRequestingMagicLink = false
            }
    }

    /// Opens the Account Management login URL, used as a fallback for magic link failures.
    private func openAccountManagementLogin() {
        if let url = URL(string: Constants.accountsURL) {
            NSWorkspace.shared.open(url)
        }
    }
}

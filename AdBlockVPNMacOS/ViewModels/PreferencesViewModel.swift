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

import Combine
import Foundation
import Sparkle

class PreferencesViewModel: ObservableObject {
    private var vpnManager: VPNManager
    private var authManager: AuthManager
    private var notificationCentre = NotificationCenter.default
    private var cancellable: AnyCancellable?
    @Published var isVpnConnected: Bool

    init(vpnManager: VPNManager, authManager: AuthManager) {
        self.authManager = authManager
        self.vpnManager = vpnManager
        self.isVpnConnected = vpnManager.connectionStatus == .connected
        setupVpnStatusSubscriber()
    }
    
    func showAccount() -> Bool {
        return authManager.isLoggedIn
    }
    
    func disconnectAndQuit() {
        NSApplication.shared.terminate(self)
    }

    private func setupVpnStatusSubscriber() {
        cancellable = self.notificationCentre.publisher(for: .NEVPNStatusDidChange)
            .sink { _ in
                self.isVpnConnected = self.vpnManager.connectionStatus == .connected
            }
    }
}

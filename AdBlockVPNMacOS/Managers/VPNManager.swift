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
import NetworkExtension
import SwiftyBeaver

class VPNManager {
    var providerManager: NETunnelProviderManager?
    var connectionStatus: NEVPNStatus? {
        return providerManager?.connection.status
    }
    
    func initializeProviderManager(callback: @escaping ((Bool) -> Void)) {
        // load any existing managers
        NETunnelProviderManager.loadAllFromPreferences { [weak self] (managers, error) in
            guard error == nil else {
                callback(false)
                return
            }
            guard let strongSelf = self else {
                callback(false)
                return
            }
            
            let vpnProfileAllowed = (managers?.count ?? 0) > 0

            // if there isn't an existing manager, create one
            if let existingManager = managers?.first {
                strongSelf.providerManager = existingManager
                callback(vpnProfileAllowed)
            } else {
                strongSelf.providerManager = NETunnelProviderManager()
                strongSelf.providerManager?.loadFromPreferences { error in
                    guard error == nil else {
                        callback(false)
                        return
                    }
                    callback(vpnProfileAllowed)
                }
            }
        }
    }
    
    func configureVPN(selectedGeo: Geo?, deviceID: String, tokenInfo: TokenInfo, callback: ((Bool) -> Void)?) {
        // Get data from OVPN config file
        guard
            let configurationFileURL = Bundle.main.url(forResource: "adblock", withExtension: "ovpn"),
            let configurationFileContent = try? Data(contentsOf: configurationFileURL)
        else {
            callback?(false)
            return
        }

        let tunnelProtocol = NETunnelProviderProtocol()

        // must be non-nil
        tunnelProtocol.serverAddress = selectedGeo?.host ?? ""

        tunnelProtocol.providerBundleIdentifier = Constants.tunnelProviderID
        
        // Set this to true so the system handles the disconnect when the main app isn't running
        tunnelProtocol.disconnectOnSleep = true
        
        // Use `providerConfiguration` to save content of the ovpn file.
        tunnelProtocol.providerConfiguration = ["ovpn": configurationFileContent,
                                                "device-id": deviceID,
                                                "access-token": tokenInfo.access_token,
                                                "refresh-token": tokenInfo.refresh_token,
                                                "expires-in": tokenInfo.expires_in,
                                                "creation-date": tokenInfo.creationDate.timeIntervalSince1970]

        providerManager?.loadFromPreferences { [weak self] error in
            guard error == nil else {
                callback?(false)
                return
            }
            guard let strongSelf = self else { return }
            
            strongSelf.providerManager?.protocolConfiguration = tunnelProtocol
            strongSelf.providerManager?.localizedDescription = "AdBlock VPN"
            strongSelf.providerManager?.isEnabled = true

            // Save configuration in the Network Extension preferences
            strongSelf.providerManager?.saveToPreferences { error in
                if let error = error {
                    SwiftyBeaver.warning("error in saving to preferences: \(error.localizedDescription)")
                    callback?(false)
                } else {
                    callback?(true)
                }
            }
        }
    }
    
    func connectVPN(callback: @escaping (String?) -> Void) {
        providerManager?.loadFromPreferences { [weak self] error in
            guard error == nil else {
                callback(error?.localizedDescription)
                return
            }
            do {
                try self?.providerManager?.connection.startVPNTunnel()
            } catch {
                callback("error in starting tunnel")
                SwiftyBeaver.warning("error in starting tunnel")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                if let status = self?.connectionStatus, status == .connected {
                    callback(nil)
                } else {
                    callback("connection failed")
                }
            }
        }
    }
    
    func disconnectVPN(callback: (() -> Void)? = nil) {
        providerManager?.loadFromPreferences { [weak self] error in
            guard error == nil else {
                callback?()
                return
            }
            self?.providerManager?.connection.stopVPNTunnel()
            callback?()
        }
    }
    
    func sendMessageToProvider(message: String, retry: Bool = false, callback: @escaping (String?) -> Void) {
        guard let messageData = message.data(using: .utf8) else { return }
        providerManager?.loadFromPreferences { [weak self] error in
            guard error == nil else {
                callback(nil)
                return
            }
            
            if let session = self?.providerManager?.connection as? NETunnelProviderSession {
                do {
                    try session.sendProviderMessage(messageData) { response in
                        if let messageResponse = response, let responseString = String(data: messageResponse, encoding: .utf8) {
                            SwiftyBeaver.verbose("send message response: \(responseString)")
                            callback(responseString)
                        } else {
                            SwiftyBeaver.debug("No response")
                            if !retry {
                                SwiftyBeaver.debug("retrying sending message to provider")
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    self?.sendMessageToProvider(message: message, retry: true, callback: callback)
                                }
                            } else {
                                callback("")
                            }
                        }
                    }
                } catch {
                    SwiftyBeaver.debug("Couldn't send message")
                    callback(nil)
                }
            } else {
                callback(nil)
            }
        }
    }
}

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

import NetworkExtension
import OpenVPNAdapter
import SwiftyBeaver

extension NEPacketTunnelFlow: OpenVPNAdapterPacketFlow {}

class PacketTunnelProvider: NEPacketTunnelProvider {
    lazy var vpnAdapter: OpenVPNAdapter = {
        let adapter = OpenVPNAdapter()
        adapter.delegate = self

        return adapter
    }()
    let authManager = AuthManager(initializeID: false)
    let errorManager = ErrorManager()
    var startHandler: ((Error?) -> Void)?
    var stopHandler: (() -> Void)?
    var reconnectVPN: Bool {
        didSet {
            UserDefaults.standard.set(reconnectVPN, forKey: Constants.reconnect_key)
        }
    }
    
    override init() {
        SwiftyBeaver.removeAllDestinations()
        let file = FileDestination()
        file.logFileURL = FileManager.default.urls(for: .cachesDirectory, in: .localDomainMask).first?.appendingPathComponent("AdBlock VPN Provider/AdBlockVPNProvider.log")
        file.format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $L: ($N: $l) $M"
        let console = ConsoleDestination()
        console.useNSLog = true
        console.format = "ABLOG: $C$L$c: ($N: $l) $M"
        SwiftyBeaver.addDestination(file)
        SwiftyBeaver.addDestination(console)
        SwiftyBeaver.verbose("PacketTunnelProvider INIT")
        reconnectVPN = UserDefaults.standard.bool(forKey: Constants.reconnect_key)
        super.init()
    }

    override func startTunnel(options: [String: NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        SwiftyBeaver.verbose("PacketTunnelProvider startTunnel")
        // get configuration that was created by the Tunnel Provider Manager
        guard
            let protocolConfiguration = protocolConfiguration as? NETunnelProviderProtocol,
            let providerConfiguration = protocolConfiguration.providerConfiguration
        else {
            SwiftyBeaver.error("PacketTunnelProvider no protocolConfiguration")
            errorManager.setRetryOrRestartError(message: "Protocol configuration error.")
            fatalError()
        }

        guard var ovpnFileContent: Data = providerConfiguration["ovpn"] as? Data else {
            SwiftyBeaver.error("PacketTunnelProvider no ovpnFileContent")
            errorManager.setRetryOrRestartError(message: "OVPN file missing.")
            fatalError()
        }
        
        guard let deviceID: String = providerConfiguration["device-id"] as? String else {
            SwiftyBeaver.error("PacketTunnelProvider no deviceID")
            errorManager.setRetryOrRestartError(message: "No deviceID found.")
            fatalError()
        }
        authManager.setDeviceID(newID: deviceID)
        
        let accessToken = providerConfiguration["access-token"] as? String ?? ""
        let refreshToken = providerConfiguration["refresh-token"] as? String ?? ""
        let expiresIn = providerConfiguration["expires-in"] as? Int ?? 0
        let creationDateInterval = providerConfiguration["creation-date"] as? Double ?? 0
        let creationDate = Date(timeIntervalSince1970: TimeInterval(creationDateInterval))
        
        // check keychain for updated token
        let storedToken = TokenInfo.newFromStored()
        if storedToken.creationDate >= creationDate && !storedToken.refresh_token.isEmpty {
            authManager.token = storedToken
        } else if !refreshToken.isEmpty {
            authManager.token = TokenInfo(accessToken: accessToken, tokenType: "bearer", expiresIn: expiresIn, refreshToken: refreshToken, creationDate: creationDate)
        }
        
        // if no token is in configuration, abort and send message that user needs to log in
        if !authManager.isLoggedIn {
            errorManager.setError(error: ErrorManager.ErrorObj(message: "You are not signed in.", type: .needsAuth, link: nil))
            SwiftyBeaver.error("PacketTunnelProvider not logged in")
            fatalError()
        }
        
        // check that auth info is indeed valid
        authManager.checkForCurrentAuthInfo { [weak self] error in
            guard let strongSelf = self else { return }
            
            if let errorMsg = error {
                switch errorMsg {
                case .invalidRefreshToken:
                    strongSelf.errorManager.setError(error: ErrorManager.ErrorObj(message: "Invalid refresh token.", type: .needsAuth, link: nil))
                case .noServer:
                    strongSelf.errorManager.setError(error: ErrorManager.ErrorObj(message: "", type: .noServer, link: nil))
                case .unknown:
                    strongSelf.errorManager.setRetryOrRestartError(message: "Unknown token error.")
                }
                SwiftyBeaver.error("in startTunnel auth error: error message: \(errorMsg)")
                fatalError()
            } else {
                // create auth-user-pass string
                let userPassString = "\n<auth-user-pass>\n\(deviceID)\n\(strongSelf.authManager.token.access_token)\n</auth-user-pass>\n"
                let userPassData = Data(userPassString.utf8)
                ovpnFileContent.append(userPassData)

                let configuration = OpenVPNConfiguration()
                configuration.fileContent = ovpnFileContent
                configuration.settings = ["remote": protocolConfiguration.serverAddress ?? "us-was.phantom.avira-vpn.com"]
               
                configuration.tunPersist = false
                configuration.retryOnAuthFailed = false
                configuration.connectionTimeout = 30

                // Apply OpenVPN configuration
                do {
                    try strongSelf.vpnAdapter.apply(configuration: configuration)
                } catch {
                    strongSelf.errorManager.setRetryOrRestartError(message: "Can't apply VPN configuration.")
                    SwiftyBeaver.warning("error in apply config: \(error.localizedDescription)")
                    completionHandler(error)
                    return
                }
                
                // Establish connection and wait for .connected event
                strongSelf.startHandler = completionHandler
                strongSelf.vpnAdapter.connect(using: strongSelf.packetFlow)
            }
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        SwiftyBeaver.debug("PacketTunnelProvider stopTunnel: \(reason.rawValue)")
        stopHandler = completionHandler
        
        // set whether or not to reconnect
        reconnectVPN = (reason != .userInitiated)

        vpnAdapter.disconnect()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        SwiftyBeaver.verbose("PacketTunnelProvider handleAppMessage")
        var response = "ack"
        if let messageString = String(data: messageData, encoding: .utf8) {
            SwiftyBeaver.debug("handleAppMessage \(messageString)")
            if messageString == "authInquiry" {
                if authManager.isLoggedIn {
                    let shouldReconnect = reconnectVPN ? 1 : 0
                    let errorSet = errorManager.isError ? 1 : 0
                    response = "\(shouldReconnect) \(authManager.token.refresh_token) \(authManager.token.creationDate.timeIntervalSince1970) \(errorSet)"
                } else {
                    response = "\(reconnectVPN ? 1 : 0) \(errorManager.isError ? 1 : 0)"
                }
            } else if messageString == "loggedOut" {
                cancelTunnelWithError(nil)
                reconnectVPN = false
                authManager.logOut()
            } else if messageString == "errorCheck" {
                if errorManager.isError {
                    response = errorManager.asteriskDelimitedString()
                    errorManager.clearError()
                }
            }
        } else {
            SwiftyBeaver.debug("received empty message")
        }
        if let handler = completionHandler {
            handler(response.data(using: .utf8))
        }
    }
}

extension PacketTunnelProvider: OpenVPNAdapterDelegate {
    // Cconfigure a tunnel
    func openVPNAdapter(_ openVPNAdapter: OpenVPNAdapter, configureTunnelWithNetworkSettings networkSettings: NEPacketTunnelNetworkSettings?, completionHandler: @escaping (Error?) -> Void) {
        SwiftyBeaver.verbose("PacketTunnelProvider configureTunnelWithNetworkSettings: \(networkSettings?.debugDescription ?? "nil")")
        networkSettings?.dnsSettings?.matchDomains = [""]
        setTunnelNetworkSettings(networkSettings) { error in
            SwiftyBeaver.debug("setSettings \((error != nil) ? (error?.localizedDescription ?? "unknown error") : "no error")")
            completionHandler(error)
        }
    }

    // Handle events
    func openVPNAdapter(_ openVPNAdapter: OpenVPNAdapter, handleEvent event: OpenVPNAdapterEvent, message: String?) {
        SwiftyBeaver.verbose("PacketTunnelProvider handleEvent: \(event.rawValue), message: \(message ?? "no message")")
        switch event {
        case .connected:
            errorManager.clearError()
            reasserting = false
            reconnectVPN = false
            
            guard let startHandler = startHandler else { return }

            startHandler(nil)
            self.startHandler = nil

        case .disconnected:
            reasserting = false
            guard let stopHandler = stopHandler else { return }
            
            stopHandler()
            self.stopHandler = nil

        case .reconnecting:
            reasserting = true

        default:
            break
        }
    }

    // Handle errors
    func openVPNAdapter(_ openVPNAdapter: OpenVPNAdapter, handleError error: Error) {
        // Handle all errors
        SwiftyBeaver.verbose("handleError: \(error.localizedDescription)")
        let fatal = (error as NSError).userInfo[OpenVPNAdapterErrorFatalKey] as? Bool ?? false
        SwiftyBeaver.verbose("error is fatal: \(fatal)")

        if let startHandler = startHandler {
            SwiftyBeaver.debug("error with startHandler: \(error)")
            startHandler(error)
            self.startHandler = nil
        } else if let stopHandler = stopHandler {
            SwiftyBeaver.debug("error with stopHandler: \(error)")
            stopHandler()
            self.stopHandler = nil
        } else {
            SwiftyBeaver.warning("error no handler: \(error)")
            reconnectVPN = true
            cancelTunnelWithError(error)
        }
    }

    // Handle log messages
    func openVPNAdapter(_ openVPNAdapter: OpenVPNAdapter, handleLogMessage logMessage: String) {
        SwiftyBeaver.debug("handleLogMessage: \(logMessage)")
    }
}

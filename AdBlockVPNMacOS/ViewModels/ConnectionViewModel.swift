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
import Alamofire
import NetworkExtension
import SwiftyBeaver
import Network

class ConnectionViewModel: ObservableObject {
    @Published var connection = ConnectionModel()
    private var vpnManager: VPNManager
    private var authManager: AuthManager
    private var logManager: LogManager
    private let notificationManager: NotificationManager
    private let errorManager: ErrorManager
    @Published var connectionButtonText = NSLocalizedString("Connect", comment: "Default label for connection button")
    @Published var connectionStateText = NSLocalizedString("Disconnected", comment: "Default text for connection state")
    @Published var regionButtonText = NSLocalizedString("Change Location", comment: "Default label for region selector")
    @Published var connectionIcon = "LockNotConnected"
    @Published var flag = ""
    @Published var grey = false
    private var shouldConnect = false
    private var userInitiated = false
    private var monitor: NWPathMonitor?
    private var restarting = false
    private var internetLostWhileConnected = false
    private var shouldBeConnected = false
    private var pingFailedCount = 0
    private var connectionStateAnimationTimer: Timer?
    private var noInternet = false
    private var userDisconnect = false
    
    init(vpnManager: VPNManager, authManager: AuthManager, logManager: LogManager, notificationManager: NotificationManager, errorManager: ErrorManager) {
        self.vpnManager = vpnManager
        self.authManager = authManager
        self.logManager = logManager
        self.notificationManager = notificationManager
        self.errorManager = errorManager
        getAvailableGeos(callback: startListening)
        registerForAllPathChanges()
    }
    
    deinit {
        stopListening()
    }
    
    private func getAvailableGeos(callback: (() -> Void)?) {
        AF.request(Constants.regionsURL).responseDecodable(of: Regions.self) { [weak self] (response) in
            if let geos = response.value {
                SwiftyBeaver.debug("downloaded regions.json")
                self?.connection.availableGeos = geos.regions
            } else if let fileURL = Bundle.main.url(forResource: "regions", withExtension: "json") {
                SwiftyBeaver.debug("couldn't download regions.json")
                do {
                    let data = try Data(contentsOf: fileURL)
                    let geos = try JSONDecoder().decode(Regions.self, from: data)
                    self?.connection.availableGeos = geos.regions
                    SwiftyBeaver.debug("regions loaded from file")
                } catch {
                    self?.errorManager.setError(
                        error: ErrorManager.ErrorObj(
                            message: NSLocalizedString("Error in reading regions file.", comment: "Reading regions file failed error."),
                            type: .needsMachineRestart,
                            link: nil
                        ))
                    SwiftyBeaver.error("can't download or parse geos from file")
                }
            } else {
                self?.errorManager.setError(
                    error: ErrorManager.ErrorObj(
                        message: NSLocalizedString("Error in reading regions file.", comment: "Downloading and reading regions file failed error"),
                        type: .needsAppRestart,
                        link: nil
                    ))
                SwiftyBeaver.error("can't download or read geos from file")
            }
            callback?()
        }
    }
    
    private func configureAndOptionallyConnect(connect: Bool, callback: ((Bool) -> Void)?) {
        if !notificationManager.allowed && connect {
            notificationManager.requestAuth()
        }
        let geoToUse = connection.availableGeos.first(where: { $0.id == connection.selectedGeo })
        vpnManager.configureVPN(selectedGeo: geoToUse, deviceID: authManager.deviceID, tokenInfo: authManager.token) { [weak self] success in
            guard let strongSelf = self else { return }
            if success {
                SwiftyBeaver.debug("configureVPN success")
                if connect {
                    strongSelf.vpnManager.connectVPN { errorMsg in
                        if let error = errorMsg {
                            SwiftyBeaver.debug("connectVPN failed: \(error)")
                            strongSelf.restarting = false
                            if strongSelf.userInitiated {
                                SwiftyBeaver.debug("connect failed userInitiated")
                                strongSelf.userInitiated = false
                                strongSelf.logManager.sendLogMessage(message: .connect_error, region: strongSelf.connection.getRegionId(), error: error)
                            }
                            callback?(false)
                        } else {
                            SwiftyBeaver.debug("connectVPN success")
                            callback?(true)
                        }
                    }
                } else {
                    callback?(true)
                }
            } else {
                strongSelf.restarting = false
                SwiftyBeaver.debug("can't configure set restarting to false")
                if strongSelf.userInitiated {
                    strongSelf.userInitiated = false
                    strongSelf.logManager.sendLogMessage(message: .connect_error,
                                                         region: strongSelf.connection.getRegionId(),
                                                         error: "VPN configuration failed")
                }
                callback?(false)
            }
        }
    }
    
    func configureVPN(callback: ((Bool) -> Void)?) {
        configureAndOptionallyConnect(connect: false) { [weak self] success in
            if !success {
                self?.errorManager.checkError = true
            }
            callback?(success)
        }
    }
    
    private func connect() {
        // if there's no internet connection now, set to reconnect when it's back
        if noInternet {
            SwiftyBeaver.debug("trying to connect but no internet")
            internetLostWhileConnected = true
        } else {
            configureAndOptionallyConnect(connect: true) { [weak self] success in
                guard let strongSelf = self else { return }
                if !success {
                    if !strongSelf.userDisconnect {
                        SwiftyBeaver.debug("connect failed check for error set")
                        strongSelf.errorManager.checkError = true
                    }
                }
            }
            connection.connectionAttempted = true
        }
    }
    
    private func disconnect() {
        vpnManager.disconnectVPN()
    }
    
    private func disconnectAndReconnect() {
        disconnect()
        shouldConnect = true
    }
    
    func restart() {
        if !restarting {
            restarting = true
            SwiftyBeaver.debug("restart set restarting to true")
            if [.connected, .connecting, .reasserting].contains(vpnManager.connectionStatus) {
                disconnectAndReconnect()
            } else {
                connect()
            }
        }
    }
    
    func toggleConnection() {
        SwiftyBeaver.verbose("connect/disconnect button clicked")
        switch vpnManager.connectionStatus {
        case .connected, .connecting, .reasserting:
            userDisconnect = true
            disconnect()
        case .disconnected, .disconnecting:
            logManager.sendLogMessage(message: .connect_attempt, region: connection.getRegionId(), nearest: connection.selectedGeo == "nearest")
            userInitiated = true
            userDisconnect = false
            connect()
        default:
            logManager.sendLogMessage(message: .connect_attempt, region: connection.getRegionId(), nearest: connection.selectedGeo == "nearest")
            userInitiated = true
            userDisconnect = false
            connect()
        }
    }
    
    func changeGeo(newGeo: String) {
        connection.selectedGeo = newGeo
        guard let status = vpnManager.connectionStatus else { return }
        if status == .connected {
            disconnect()
            shouldConnect = true
            userInitiated = true
            logManager.sendLogMessage(message: .connect_attempt, region: connection.getRegionId(), nearest: connection.selectedGeo == "nearest")
        } else {
            updateView(status: status)
        }
    }
    
    private func startListening() {
        updateViewBasedOnCurrentState()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: nil, queue: OperationQueue.main) { [weak self] _ in
            guard let strongSelf = self else { return }
            guard let status = strongSelf.vpnManager.connectionStatus else { return }
            strongSelf.updateView(status: status)
            if strongSelf.shouldConnect, status == .disconnected {
                strongSelf.shouldConnect = false
                strongSelf.connect()
            }
            if strongSelf.userInitiated, status == .connected {
                strongSelf.userInitiated = false
                strongSelf.shouldConnect = false
                strongSelf.logManager.sendLogMessage(message: .connect_success, region: strongSelf.connection.getRegionId())
            }
            if status == .connected {
                strongSelf.userDisconnect = false
                strongSelf.restarting = false
                SwiftyBeaver.debug("connected set restarting to false")
                strongSelf.shouldBeConnected = true
            } else if status == .disconnected || status == .disconnecting {
                strongSelf.shouldBeConnected = false
            } else if status == .invalid {
                // TODO: handle invalid status better
                SwiftyBeaver.debug("status is INVALID")
            } 
            if status != .disconnecting {
                strongSelf.notificationManager.sendNotification(type: .connection, message: strongSelf.connection.getNotificationText(status: status),
                                                                imageName: strongSelf.connection.getNotificationFlag(status: status))
            }
        }
    }
    
    func updateViewBasedOnCurrentState() {
        let status = vpnManager.connectionStatus ?? .disconnected
        updateView(status: status)
    }
    
    private func stopListening() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
    }
    
    private func updateView(status: NEVPNStatus) {
        var vpnStatus = status
        if !connection.connectionAttempted && status == .invalid {
            vpnStatus = .disconnected
        }
        connectionStateText = connection.getStateText(status: vpnStatus)
        connectionButtonText = connection.getActionText(status: vpnStatus)
        regionButtonText = connection.getRegionText(status: vpnStatus)
        connectionIcon = connection.getIcon(status: vpnStatus)
        flag = connection.getFlag(status: vpnStatus)
        grey = connection.isGreyed(status: vpnStatus)

        // Timer to update `connectionStateText` if VPN is in the `Connecting` or `Disconnecting` state.
        connectionStateAnimationTimer?.invalidate()
        if vpnStatus == .connecting || vpnStatus == .disconnecting {
            connectionStateAnimationTimer = Timer.scheduledTimer(timeInterval: 0.8,
                                                                 target: self,
                                                                 selector: #selector(animateConnectionStateText),
                                                                 userInfo: nil,
                                                                 repeats: true)
        }
    }

    /// When called repeatedly with a timer, this function iterates between 1-3 periods as a suffix to the connectionStateText.
    @objc private func animateConnectionStateText() {
        let periodCharacter: Character = "."
        let periodCount = connectionStateText.filter { $0 == periodCharacter }.count
        switch periodCount {
        case 1, 2:
            connectionStateText += "."
        default:
            connectionStateText = connectionStateText.filter { $0 != periodCharacter } + "."
        }
    }
    
    private func ping() {
        let uniqueID = UUID()
        if let url = URL(string: "https://www.google.com") {
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 10
            sessionConfig.timeoutIntervalForResource = 25
            
            URLSession(configuration: sessionConfig).dataTask(with: request) { [weak self] (_, response, error) in
                guard let strongSelf = self else { return }
                guard error == nil else {
                    SwiftyBeaver.warning("ping \(uniqueID) failed: \(error.debugDescription)")
                    if !strongSelf.restarting {
                        if strongSelf.pingFailedCount < 2 {
                            strongSelf.restarting = true
                            SwiftyBeaver.debug("ping \(uniqueID) failed set restarting to true")
                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                SwiftyBeaver.debug("ping \(uniqueID) failed restart connection")
                                strongSelf.pingFailedCount += 1
                                SwiftyBeaver.verbose("ping failed count: \(strongSelf.pingFailedCount)")
                                strongSelf.disconnectAndReconnect()
                            }
                        } else {
                            strongSelf.errorManager.setError(error: ErrorManager.ErrorObj(message: "Connection cannot be established (too many retries).", type: .needsSupport, link: nil))
                            strongSelf.disconnect()
                        }
                    }
                    return
                }
                
                guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                    SwiftyBeaver.warning("ping \(uniqueID) failed status != 200")
                    return
                }
                
                SwiftyBeaver.debug("ping \(uniqueID) status == 200")
                if strongSelf.vpnManager.connectionStatus == .connected {
                    strongSelf.pingFailedCount = 0
                }
            }.resume()
            SwiftyBeaver.debug("sending ping \(uniqueID)")
        }
    }
    
    private func registerForAllPathChanges() {
        if monitor != nil { return }
        
        monitor = NWPathMonitor()
        
        let pathUpdateHandler = { [weak self] (path: Network.NWPath) in
            guard let strongSelf = self else { return }
            strongSelf.noInternet = !path.availableInterfaces.contains(where: { $0.type == .wifi || $0.type == .wiredEthernet })
            
            SwiftyBeaver.debug("path change: \(path.debugDescription)")
            
            if strongSelf.shouldBeConnected {
                if strongSelf.noInternet {
                    strongSelf.internetLostWhileConnected = true
                    SwiftyBeaver.debug("no internet")
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        SwiftyBeaver.debug("no internet disconnect")
                        strongSelf.disconnect()
                    }
                } else if path.status == .unsatisfied && !strongSelf.restarting && !strongSelf.internetLostWhileConnected {
                    strongSelf.restarting = true
                    SwiftyBeaver.debug("path unsatisfied set restarting to true")
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        SwiftyBeaver.debug("path change unsatisfied restart connection")
                        strongSelf.disconnectAndReconnect()
                    }
                }
                
                if path.status == .satisfied && path.availableInterfaces.contains(where: { $0.type == .other }) && !strongSelf.noInternet {
                    strongSelf.ping()
                }
            }
            
            if path.status != .unsatisfied
                && path.availableInterfaces.contains(where: { $0.type == .wifi || $0.type == .wiredEthernet })
                && strongSelf.internetLostWhileConnected {
                strongSelf.internetLostWhileConnected = false
                SwiftyBeaver.debug("internet lost try to reconnect")
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    SwiftyBeaver.debug("internet lost restarting connection")
                    strongSelf.connect()
                }
            }
        }
        
        monitor?.pathUpdateHandler = pathUpdateHandler
        let queue = DispatchQueue.init(label: "pathMonitorQueue", qos: .userInitiated)
        monitor?.start(queue: queue)
        SwiftyBeaver.verbose("start listening for path changes")
    }
}

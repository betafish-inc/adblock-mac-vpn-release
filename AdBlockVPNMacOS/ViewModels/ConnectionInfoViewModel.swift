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
import NetworkExtension
import SwiftUI
import SwiftyBeaver

class ConnectionInfoViewModel: ObservableObject {
    private var vpnManager: VPNManager
    private var connectionTimeTimer = Timer()
    private var connectedSecondsElapsed = 0
    private var connectionStatusCached: NEVPNStatus?
    private let connectedTimeFormatter = DateComponentsFormatter()
    private let notificationCenter = NotificationCenter.default
    @Published var ipv4Address = "--"
    @Published var ipv6Address = "--"
    @Published var ipError = false
    @Published var connectedTime = "--"
    @Published var vpnConnected = false

    init(vpnManager: VPNManager) {
        self.vpnManager = vpnManager
        startListening()
        connectedTimeFormatter.allowedUnits = [.hour, .minute, .second]
        connectedTimeFormatter.unitsStyle = .short
        updateIPAddresses()
    }

    deinit {
        stopListening()
    }

    private func startListening() {
        notificationCenter.addObserver(self, selector: #selector(updateIPAddresses), name: Constants.connectionSatisfiedNotification, object: nil)
        notificationCenter.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: nil, queue: OperationQueue.main) { [weak self] _ in
            guard let strongSelf = self else { return }
            guard let status = strongSelf.vpnManager.connectionStatus else { return }

            // `NEVPNStatusDidChange` can broadcast the same notification sequentially. As we only need to react to unique status changes,
            // we can return early if the connection status matches the previously cached status.
            if status == strongSelf.connectionStatusCached { return }
            strongSelf.connectionStatusCached = status
            strongSelf.updateView(status: status)
        }
    }

    private func stopListening() {
        notificationCenter.removeObserver(self, name: Constants.connectionSatisfiedNotification, object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
    }

    private func updateView(status: NEVPNStatus) {
        switch status {
        case .connected:
            vpnConnected = true
            if connectionTimeTimer.isValid { return }
            connectedTime = "--"
            connectionTimeTimer = Timer.scheduledTimer(timeInterval: 1,
                                                       target: self,
                                                       selector: #selector(incrementConnectedTime),
                                                       userInfo: nil,
                                                       repeats: true)
        case .disconnected:
            vpnConnected = false
            connectionTimeTimer.invalidate()
            connectedSecondsElapsed = 0
            connectedTime = "--"
        case .connecting, .disconnecting, .invalid:
            ipv4Address = "--"
            ipv6Address = "--"
        default:
            return
        }
    }

    /// This function formats, sets then increments the connected time. Designed to be called every second whilst VPN is connected.
    @objc private func incrementConnectedTime() {
        connectedSecondsElapsed += 1
        connectedTime = connectedTimeFormatter.string(from: TimeInterval(connectedSecondsElapsed)) ?? "--"
    }

    /// Requests an update to the IP Addresses.
    @objc func updateIPAddresses() {
        DispatchQueue.main.async {
            self.ipv4Address = "--"
            self.ipv6Address = "--"
        }
        refreshIPAddress(for: .ipv4)
        refreshIPAddress(for: .ipv6)
    }

    /// Refreshes and sets the IP Address for the IP Version specified to the published variable.
    /// - Parameters:
    ///   - ipVersion: The IP Version required to refresh - IPv4 or IPv6.
    private func refreshIPAddress(for ipVersion: IPVersion) {
        // Assign correct endpoint URL for IP Version required
        let url = ipVersion == .ipv4 ? Constants.ipv4ConnectionInfoURL : Constants.ipv6ConnectionInfoURL

        // Cancel any existing tasks
        AF.session.getAllTasks { tasks in
            tasks.forEach { task in
                if task.originalRequest?.url?.absoluteString == url {
                    SwiftyBeaver.verbose("IP Address Cancel Task: \(task)")
                    task.cancel()
                }
            }
        }

        // Request data from server
        SwiftyBeaver.verbose("Updating IP Address")
        let headers: HTTPHeaders = ["content-type": "application/json"]
        AF.request(url, method: .get, headers: headers)
            .responseDecodable(of: IPAddress.self) { response in
                switch response.result {
                case .success(let response):
                    SwiftyBeaver.verbose("IP Address Updated")
                    self.ipError = false
                    switch ipVersion {
                    case .ipv4:
                        self.ipv4Address = response.ip
                    case.ipv6:
                        self.ipv6Address = response.ip
                    }
                case .failure(let error):
                    SwiftyBeaver.warning("IP Address Update Failed: \(String(describing: error.errorDescription))")
                    // The following failures are intentionally ignored:
                    // Error caused by network task being manually cancelled - this uses error code `-999`
                    // Error caused by being unable to connect to the IPv6 hostname on incompatible network - this uses error code `-1003` or `-1004`
                    if let urlError = error.underlyingError as? URLError,
                       urlError.code.rawValue == -999 || (urlError.code.rawValue == -1003 || urlError.code.rawValue == -1004 && ipVersion == .ipv6) {
                        SwiftyBeaver.warning("IP Address Update Error Ignored")
                        return
                    }
                    self.ipError = true
                }
            }
    }
}

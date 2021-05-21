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
import Alamofire
import SwiftyBeaver

class LogManager {
    let formatter = ISO8601DateFormatter()
    
    enum LogType: String, Encodable {
        case connect_attempt
        case connect_success
        case connect_error
        case install_attempt
        case install_success
        case install_failure
        case update
        case ping
    }
    
    func sendLogMessage(message: LogType, region: String? = nil, nearest: Bool? = nil, error: String? = nil, target: String? = nil, callback: ((Bool) -> Void)? = nil) {
        var params: LogData
        let timeStamp = formatter.string(from: Date())
        if let regionID = region, let errorMsg = error {
            params = LogData(event: message, regionID: regionID, errorMsg: errorMsg, timeStamp: timeStamp)
        } else if let regionID = region {
            params = LogData(event: message, regionID: regionID, nearestFlag: nearest ?? false)
        } else if let errorMsg = error {
            params = LogData(event: message, errorMsg: errorMsg, timeStamp: formatter.string(from: Date()))
        } else if let targetVersion = target {
            params = LogData(event: message, timeStamp: timeStamp, targetVersion: targetVersion)
        } else if message == .ping {
            params = LogData(event: message, timeStamp: timeStamp)
        } else {
            params = LogData(event: message)
        }
        AF.request(Constants.logURL, method: .post, parameters: params, encoder: JSONParameterEncoder.default).validate().response { response in
            switch response.result {
            case .success:
                SwiftyBeaver.verbose("Log message \(message) successfully sent")
                callback?(true)
            case let .failure(err):
                SwiftyBeaver.warning("Log message \(message) failed: \(err)")
                callback?(false)
            }
        }
    }
    
    private struct LogData: Encodable {
        var event: LogType
        var payload: Payload
        
        init(event: LogType) {
            self.event = event
            payload = Payload()
        }
        
        init(event: LogType, timeStamp: String) {
            self.event = event
            payload = Payload(timeStamp: timeStamp, sys_info: ProcessInfo().operatingSystemVersionString)
        }
        
        init(event: LogType, timeStamp: String, targetVersion: String) {
            self.event = event
            payload = Payload(timeStamp: timeStamp, target: targetVersion, sys_info: ProcessInfo().operatingSystemVersionString)
        }
        
        init(event: LogType, regionID: String, nearestFlag: Bool) {
            self.event = event
            payload = Payload(region: regionID, nearest: nearestFlag ? nearestFlag : nil)
        }
        
        init(event: LogType, errorMsg: String, timeStamp: String) {
            self.event = event
            payload = Payload(error: errorMsg, timeStamp: timeStamp)
        }
        
        init(event: LogType, regionID: String, errorMsg: String, timeStamp: String) {
            self.event = event
            payload = Payload(region: regionID, error: errorMsg, timeStamp: timeStamp)
        }
    }
    
    struct Payload: Encodable {
        var device = UserDefaults.standard.string(forKey: Constants.deviceID_key) ?? "unknown"
        var version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        var channel: String? = Constants.channelName == "production" ? nil : Constants.channelName
        var os_version = getOSVersion()
        var flavor = "vm"
        var region: String?
        var nearest: Bool?
        var error: String?
        var timeStamp: String?
        var target: String?
        var sys_info: String?
        
        static func getOSVersion() -> String {
            let version = ProcessInfo().operatingSystemVersion
            return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        }
    }
}

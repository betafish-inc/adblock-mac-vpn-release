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
import SwiftyBeaver

class AuthManager {
    enum AuthError: String {
        case noServer
        case invalidRefreshToken
        case unknown
    }
    
    private(set) var deviceID: String
    private(set) var loggedOut: Date? {
        didSet {
            if let loggedOutDate = loggedOut {
                UserDefaults.standard.set(loggedOutDate.timeIntervalSince1970, forKey: Constants.loggedOut_key)
            } else {
                UserDefaults.standard.removeObject(forKey: Constants.loggedOut_key)
            }
        }
    }
    @Published var token: TokenInfo {
        didSet {
            token.save()
        }
    }
    var isLoggedIn: Bool { !isLoggedOut }
    var isAuthorized: Bool { token.isActive && isLoggedIn }
    var isLoggedOut: Bool {
        if token.refresh_token.isEmpty {
            return true
        }
        if let loggedOutDate = loggedOut, loggedOutDate >= token.creationDate {
            return true
        }
        return false
    }
    
    init(initializeID: Bool = true) {
        if initializeID {
            // retrieve saved device ID
            if let savedID = UserDefaults.standard.string(forKey: Constants.deviceID_key) {
                deviceID = savedID
            } else {
                var uniqueID = UUID.init().uuidString
                uniqueID = uniqueID.replacingOccurrences(of: "-", with: "").lowercased()
                deviceID = "0442-\(uniqueID)00000000"
                UserDefaults.standard.set(deviceID, forKey: Constants.deviceID_key)
            }
        } else {
            deviceID = ""
        }
        
        // retrieve saved loggedOut date
        let savedLoggedOut = UserDefaults.standard.double(forKey: Constants.loggedOut_key)
        if savedLoggedOut != 0 {
            loggedOut = Date(timeIntervalSince1970: TimeInterval(savedLoggedOut))
        }
        
        // retrieve saved refresh token
        token = TokenInfo.newFromStored()
        SwiftyBeaver.debug("tokenInfo on init: \(token)")
    }
    
    func setDeviceID(newID: String) {
        deviceID = newID
    }
    
    func getNewAccessToken(callback: @escaping (AuthError?) -> Void) {
        SwiftyBeaver.debug("current tokenInfo: \(token)")
        AF.request(Constants.refreshURL,
                   method: .post,
                   parameters: ["grant_type": "refresh_token",
                                "refresh_token": token.refresh_token,
                                "device_id": deviceID],
                   encoder: JSONParameterEncoder.default).validate().responseDecodable(of: TokenInfo.self) { [weak self] response in
                    switch response.result {
                    case let .success(tokenInfo):
                        SwiftyBeaver.verbose("tokenInfo: \(tokenInfo)")
                        self?.token = tokenInfo
                        callback(nil)
                    case let .failure(err):
                        var authErr: AuthError = .unknown
                        SwiftyBeaver.warning("token failure: \(err)")
                        if err.isResponseValidationError && (err.responseCode == 400 || err.responseCode == 401) {
                            SwiftyBeaver.warning("token unrecoverable logging out")
                            self?.logOut()
                            authErr = .invalidRefreshToken
                        } else if let code = err.responseCode, code >= 500 {
                            authErr = .noServer
                        }
                        if let responseData = response.data {
                            let responseDataString = String(data: responseData, encoding: .utf8)
                            SwiftyBeaver.warning("token error msg: \(responseDataString ?? "no error message")")
                        }
                        callback(authErr)
                    }
        }
    }
    
    func logOut() {
        SwiftyBeaver.debug("current tokenInfo: \(token)")
        AF.request(Constants.logOutURL,
                   method: .post,
                   parameters: ["token": token.access_token,
                                "device_id": deviceID],
                   encoder: JSONParameterEncoder.default).validate().response { response in
                    switch response.result {
                    case .success:
                        SwiftyBeaver.verbose("Logged OUT")
                    case let .failure(err):
                        SwiftyBeaver.debug("log out error: \(err)")
                        if let responseData = response.data {
                            let responseDataString = String(data: responseData, encoding: .utf8)
                            SwiftyBeaver.debug("log out error msg: \(responseDataString ?? "no error message")")
                        }
                    }
        }
        loggedOut = Date()
        token.clear()
    }
    
    func checkForCurrentAuthInfo(callback: @escaping (AuthError?) -> Void) {
        SwiftyBeaver.debug("current tokenInfo: \(token)")
        if !isAuthorized {
            getNewAccessToken { (errorMsg) in
                callback(errorMsg)
            }
        } else {
            callback(nil)
        }
    }
}

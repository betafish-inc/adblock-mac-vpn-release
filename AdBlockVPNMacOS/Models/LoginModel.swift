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

enum LoginError {
    case noServer
    case generic
    case invalidEmail
    case invalidCode
    case noAccount
    case subEnded
    case deviceLimit
    case loggedOut
}

class LoginManager {
    private var loginData = LoginResponse()
    private var emailString = ""
    var emailSubmitted = false
    
    func confirmEmail(authString: String, deviceID: String, callback: @escaping (LoginError?, TokenInfo?) -> Void) {
        // Add device name ie 'Rachel's macBook Pro'
        AF.request(Constants.confirmURL,
                   method: .post,
                   parameters: ["email": emailString,
                                "device_id": deviceID,
                                "auth_id": loginData.auth_id,
                                "auth_code": authString],
                   encoder: JSONParameterEncoder.default).validate().responseDecodable(of: TokenInfo.self) { [weak self] response in
                    guard let strongSelf = self else { return }
                    switch response.result {
                    case let .success(tokenInfo):
                        SwiftyBeaver.verbose("confirm email token: \(tokenInfo)")
                        callback(nil, tokenInfo)
                    case let .failure(err):
                        if let code = err.responseCode, code >= 500 {
                            callback(.noServer, nil)
                            return
                        }
                        let errorMsg = strongSelf.getErrorMsg(response: response.data)
                        SwiftyBeaver.warning("confirm email error: \(errorMsg.isEmpty ? "no error message" : errorMsg)")
                        if errorMsg == "auth_code_expired" || errorMsg == "auth_code_invalid" {
                            callback(.invalidCode, nil)
                        } else if errorMsg == "insufficient_funds" {
                            callback(.subEnded, nil)
                        } else if errorMsg == "purchase_required" {
                            callback(.noAccount, nil)
                        } else if errorMsg == "device_limit_reached" {
                            callback(.deviceLimit, nil)
                        } else {
                            callback(.generic, nil)
                        }
                    }
        }
    }
    
    func submitEmail(emailString: String, callback: @escaping (LoginError?) -> Void) {
        self.emailString = emailString
        AF.request(Constants.emailURL,
                   method: .post,
                   parameters: ["email": emailString],
                   encoder: JSONParameterEncoder.default).validate().responseDecodable(of: LoginResponse.self) { [weak self] response in
                    guard let strongSelf = self else { return }
                    switch response.result {
                    case let .success(responseObj):
                        SwiftyBeaver.verbose("submit email response: \(responseObj)")
                        strongSelf.loginData = responseObj
                        strongSelf.emailSubmitted = true
                        callback(nil)
                    case let .failure(err):
                        if let code = err.responseCode, code >= 500 {
                            callback(.noServer)
                            return
                        }
                        let errorMsg = strongSelf.getErrorMsg(response: response.data)
                        SwiftyBeaver.warning("submit email error: \(errorMsg.isEmpty ? "no error message" : errorMsg)")
                        if errorMsg == "no_email_provided_in_request" {
                            callback(.invalidEmail)
                        } else {
                            callback(.generic)
                        }
                    }
        }
    }
    
    func reset() {
        loginData = LoginResponse()
        emailString = ""
        emailSubmitted = false
    }
    
    private func getErrorMsg(response: Data?) -> String {
        if let responseData = response {
            do {
                if let jsonResponseData = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
                   let errorMsg = jsonResponseData["err"] as? String {
                    return errorMsg
                }
            } catch {
                SwiftyBeaver.warning("JSON error")
            }
        }
        return ""
    }
}

extension LoginManager {
    struct LoginResponse: Decodable {
        var auth_id: String = ""
    }
}

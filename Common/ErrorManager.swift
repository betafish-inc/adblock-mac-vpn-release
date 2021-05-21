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
import SwiftyBeaver

class ErrorManager {
    // Order of declaration matters here - they should be in priority order
    enum ErrorType: Int, Comparable {
        case noInternet
        case needsMachineRestart
        case needsAppRestart
        case noServer
        case needsAuth
        case needsSupport
        case needsKB
        case retryConnection // TODO: doesn't actually trigger retry yet
        
        static func < (lhs: ErrorType, rhs: ErrorType) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }
    
    struct ErrorStrings {
        var fullAction: String
        var shortAction: String
        var errorWebLinks: [String: String]?
    }
    
    struct AppErrorString {
        var text: String
        var links: [String: String]?
    }
    
    struct ErrorObj {
        var message: String
        var type: ErrorType
        var link: String?
        var isSolvable: Bool {
            return [.noInternet, .noServer, .needsAuth, .retryConnection].contains(type)
        }
        var isUserFacing: Bool {
            return type != .retryConnection
        }

        func toString() -> String {
            return "Error message: \(message) type: \(type.rawValue) link: \(link ?? "no link")"
        }
    }
    
    let errorStrings: [ErrorType: ErrorStrings] = [
        .noInternet: ErrorStrings(
            fullAction: "You aren't connected to the internet!\nPlease check your network connection.",
            shortAction: "You aren't connected to the internet!\nPlease check your network connection.",
            errorWebLinks: nil),
        .needsAppRestart: ErrorStrings(
            fullAction: "Please restart AdBlock VPN. If the problem persists, contact our support team.",
            shortAction: "Please restart AdBlock VPN",
            errorWebLinks: ["support team": Constants.helpURL]),
        .needsMachineRestart: ErrorStrings(
            fullAction: "Please restart your computer. If the problem persists, contact our support team.",
            shortAction: "Please restart your computer",
            errorWebLinks: ["support team": Constants.helpURL]),
        .needsKB: ErrorStrings(
            fullAction: "For help solving this problem, please follow the steps in this article.",
            shortAction: "Please follow the steps in this article",
            errorWebLinks: nil),
        .needsSupport: ErrorStrings(
            fullAction: "For help solving this problem, please contact our support team.",
            shortAction: "Please contact our support team",
            errorWebLinks: ["support team": Constants.helpURL]),
        .needsAuth: ErrorStrings(
            fullAction: "Please sign in again. If the problem persists, contact our support team.",
            shortAction: "Please sign in again",
            errorWebLinks: ["support team": Constants.helpURL]),
        .noServer: ErrorStrings(
            fullAction: "We can't connect to our servers. Please try again later. If the problem persists, contact our support team.",
            shortAction: "We can't connect to our servers. Please try again later.",
            errorWebLinks: ["support team": Constants.helpURL])
    ]
    
    @Published var isError = false
    @Published var checkError = false
    private var err: ErrorObj? {
        didSet {
            SwiftyBeaver.debug("error set in Error Manager: \(err?.toString() ?? "nil")")
            UserDefaults.standard.set(asteriskDelimitedString(), forKey: Constants.lastError_key)
            newError = false
            if let error = err, oldValue == nil {
                if error.isUserFacing {
                    newError = true
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        self.isError = true
                    }
                }
            } else if let error = err, error.isUserFacing, let oldErr = oldValue, error.type != oldErr.type {
                newError = true
            } else if err == nil || !(err?.isUserFacing ?? false) {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.isError = false
                }
            }
        }
    }
    var newError = false
    var isAuthError: Bool {
        return err?.type == .needsAuth
    }
    
    init() {
        if let savedError = UserDefaults.standard.string(forKey: Constants.lastError_key) {
            setFromAsteriskDelimitedString(asteriskString: savedError)
        }
    }
    
    func setError(error: ErrorObj) {
        if err == nil {
            err = error
        } else if let currErr = err, error.type < currErr.type {
            // replace error only with higher priority error
            err = error
        }
    }
    
    func clearError() {
        // can only clear solvable errors
        if let error = err, error.isSolvable {
            err = nil
        }
    }
    
    // to force clear the error -- used for main app initialization
    func resetErrorState() {
        err = nil
    }
    
    func getFullAppMessage() -> AppErrorString {
        guard let error = err else { return AppErrorString(text: "", links: nil) }
        if error.type == .noInternet {
            return AppErrorString(text: errorStrings[error.type]?.fullAction ?? "", links: nil)
        } else {
            var links = errorStrings[error.type]?.errorWebLinks
            // Check for KB link
            if let link = error.link, error.type == .needsKB {
                links = ["contact support": link]
            }
            let text = error.message.isEmpty ? errorStrings[error.type]?.fullAction ?? "" : "\(error.message)\n\(errorStrings[error.type]?.fullAction ?? "")"
            return AppErrorString(text: text, links: links)
        }
    }
    
    func getFullNotificationMessage() -> String {
        guard let error = err else { return "" }
        if error.type == .noInternet {
            return errorStrings[error.type]?.shortAction ?? ""
        } else {
            let text = error.message.isEmpty ? errorStrings[error.type]?.shortAction ?? "" : "\(error.message)\n\(errorStrings[error.type]?.shortAction ?? "")"
            return text
        }
    }
    
    func asteriskDelimitedString() -> String {
        if let error = err {
            return "\(error.message)*\(error.type.rawValue)*\(error.link ?? "nil")"
        } else {
            return ""
        }
    }
    
    // swiftlint:disable:next inclusive_language
    func setFromAsteriskDelimitedString(asteriskString: String) {
        var message = ""
        var errType: Int?
        var link = ""
        
        let errorArray = asteriskString.split(separator: "*")
        if errorArray.count == 2 {
            message = ""
            errType = Int(errorArray[0])
            link = String(errorArray[1])
        } else if errorArray.count == 3 {
            message = String(errorArray[0])
            errType = Int(errorArray[1])
            link = String(errorArray[2])
        }
        let errNum = errType ?? ErrorManager.ErrorType.retryConnection.rawValue
        let errorType = ErrorManager.ErrorType(rawValue: errNum) ?? .retryConnection
        let errLink = link == "nil" ? nil : link
        setError(error: ErrorObj(message: message, type: errorType, link: errLink))
    }
    
    func setRetryOrRestartError(message: String) {
        if err?.type == .retryConnection {
            setError(error: ErrorObj(message: message, type: .needsAppRestart, link: nil))
        } else {
            setError(error: ErrorObj(message: "", type: .retryConnection, link: nil))
        }
    }
}

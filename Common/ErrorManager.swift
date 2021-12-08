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
        case retryConnection
        
        static func < (lhs: ErrorType, rhs: ErrorType) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }
    
    struct ErrorStrings {
        var fullAction: String
        var shortAction: String
        var errorWebLink: String?
    }
    
    struct AppErrorString {
        var text: String
        var link: String?
        var inlineLink = false
    }
    
    struct ErrorObj {
        var message: String
        var type: ErrorType
        var link: String?
        var isUserFacing: Bool {
            return type != .retryConnection
        }

        func toString() -> String {
            return "Error message: \(message) type: \(type.rawValue) link: \(link ?? "no link")"
        }
    }
    
    let errorStrings: [ErrorType: ErrorStrings] = [
        .noInternet: ErrorStrings(
            fullAction: NSLocalizedString("You aren't connected to the internet! Please check your network connection.", comment: "No internet error full msg"),
            shortAction: NSLocalizedString("You aren't connected to the internet!\nPlease check your network connection.", comment: "No internet error short msg")),
        .needsAppRestart: ErrorStrings(
            fullAction: NSLocalizedString("Please restart AdBlock VPN.", comment: "Needs app restart error full msg"),
            shortAction: NSLocalizedString("Please restart AdBlock VPN", comment: "Needs app restart short msg")),
        .needsMachineRestart: ErrorStrings(
            fullAction: NSLocalizedString("Please restart your computer.", comment: "Needs machine restart error full msg"),
            shortAction: NSLocalizedString("Please restart your computer", comment: "Needs machine restart short msg"),
            errorWebLink: Constants.needMachineRestartURL),
        .needsKB: ErrorStrings(
            fullAction: NSLocalizedString("For help solving this problem, please follow the steps in this article.", comment: "Needs knowledge base article error full msg"),
            shortAction: NSLocalizedString("Please follow the steps in this article", comment: "Needs knowledge base article error short msg"),
            errorWebLink: nil),
        .needsSupport: ErrorStrings(
            fullAction: NSLocalizedString("For help solving this problem, please contact our support team.", comment: "Link to support site"),
            shortAction: NSLocalizedString("Please contact our support team", comment: "Needs support error short msg")),
        .needsAuth: ErrorStrings(
            fullAction: NSLocalizedString("Please sign in again.", comment: "Needs authentication error full msg"),
            shortAction: NSLocalizedString("Please sign in again", comment: "Needs authentication short msg")),
        .noServer: ErrorStrings(
            fullAction: NSLocalizedString("We can't connect to our servers. Please try again later.",
                                          comment: "Server error full msg"),
            shortAction: NSLocalizedString("We can't connect to our servers. Please try again later.", comment: "Server error short msg"),
            errorWebLink: Constants.connectionHelpURL)
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
                }
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.isError = true
                }
            } else if let error = err, error.isUserFacing, let oldErr = oldValue, error.type != oldErr.type {
                newError = true
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.isError = true
                }
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
    var isRetryError: Bool {
        return err?.type == .retryConnection
    }
    var isUserFacingError: Bool {
        return err?.isUserFacing ?? false
    }
    var isMainError: Bool {
        return isUserFacingError && err?.type != .needsAuth
    }
    private var restarted = false
    
    init() {
        if let savedError = UserDefaults.standard.string(forKey: Constants.lastError_key), !savedError.isEmpty {
            setFromAsteriskDelimitedString(asteriskString: savedError)
            if err?.type == .retryConnection {
                restarted = true
            }
        }
    }
    
    func setError(error: ErrorObj) {
        if err == nil {
            err = error
        } else if let currErr = err {
            if isRetryError && error.type == .retryConnection {
                err = ErrorObj(message: NSLocalizedString("Connection retry failed.", comment: "Error msg when connection retry fails"), type: .needsAppRestart, link: nil)
            } else if error.type < currErr.type {
                // replace error only with higher priority error
                err = error
            }
        }
    }
    
    func clearError() {
        err = nil
    }
    
    func getFullAppMessage() -> AppErrorString {
        guard let error = err else { return AppErrorString(text: "", link: nil) }
        var inlineLink = false
        if error.type == .noInternet {
            return AppErrorString(text: errorStrings[error.type]?.fullAction ?? "", link: nil)
        } else {
            var kbLink = errorStrings[error.type]?.errorWebLink
            // Check for KB link
            if let link = error.link, error.type == .needsKB {
                kbLink = link
                inlineLink = true
            }
            let text = error.message.isEmpty ? errorStrings[error.type]?.fullAction ?? "" : "\(error.message) \(errorStrings[error.type]?.fullAction ?? "")"
            return AppErrorString(text: text, link: kbLink, inlineLink: inlineLink)
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
        SwiftyBeaver.debug("setFromAsteriskDelimitedString: \(asteriskString)")
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
        
        let errLink = link == "nil" ? nil : link
        if let errNum = errType, let errorType = ErrorManager.ErrorType(rawValue: errNum) {
            setError(error: ErrorObj(message: message, type: errorType, link: errLink))
        }
    }
    
    func setRetryOrRestartError(message: String) {
        if (err?.type == .retryConnection) && restarted {
            setError(error: ErrorObj(message: message, type: .needsAppRestart, link: nil))
        } else {
            setError(error: ErrorObj(message: "", type: .retryConnection, link: nil))
        }
    }
}

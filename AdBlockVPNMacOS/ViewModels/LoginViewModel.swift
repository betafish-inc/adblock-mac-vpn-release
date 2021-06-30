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
import AppKit
import SwiftyBeaver

class LoginViewModel: ObservableObject {
    private var loginManager = LoginManager()
    private var authManager: AuthManager
    private var logManager: LogManager
    private var errorManager: ErrorManager
    private var error: LoginError? = nil {
        didSet {
            switch error {
            case nil:
                errorStrings = LoginViewModel.genericErrorText
                isError = false
            case .deviceLimit:
                currentPage = .deviceLimitError
                isError = true
            case .noAccount:
                currentPage = .noAccountError
                isError = true
            case .subEnded:
                currentPage = .subEndedError
                isError = true
            case .invalidEmail:
                errorStrings = LoginViewModel.invalidEmailErrorText
                isError = true
            case .invalidCode:
                errorStrings = LoginViewModel.invalidCodeErrorText
                isError = true
            case .generic:
                errorStrings = LoginViewModel.genericErrorText
                isError = true
            case .noServer:
                errorStrings = LoginViewModel.genericErrorText
                isError = true
                errorManager.setError(error: ErrorManager.ErrorObj(message: "", type: .noServer, link: nil))
            case .loggedOut:
                errorStrings = LoginViewModel.loggedOutErrorText
                isError = true
                errorManager.clearError()
            }
        }
    }
    @Published var pageStrings = LoginViewModel.emailEntryText
    @Published var currentPage = LoginPages.emailEntry {
        didSet {
            switch currentPage {
            case .emailEntry:
                pageStrings = LoginViewModel.emailEntryText
            case .codeEntry:
                pageStrings = LoginViewModel.codeEntryText
            case .noAccountError:
                pageStrings = LoginViewModel.noAccountText
            case .subEndedError:
                pageStrings = LoginViewModel.subEndedText
            case .deviceLimitError:
                pageStrings = LoginViewModel.deviceLimitText
            }
        }
    }
    @Published var isTransition = false {
        didSet {
            SwiftyBeaver.verbose("isTransition: \(isTransition)")
            if isTransition == false {
                isSpinning = false
            }
        }
    }
    @Published var isSpinning = false
    @Published var isError = false
    @Published var errorStrings = LoginViewModel.genericErrorText
    
    init(authManager: AuthManager, logManager: LogManager, errorManager: ErrorManager) {
        self.authManager = authManager
        self.logManager = logManager
        self.errorManager = errorManager
    }
    
    func submitAuthString(authString: String, callback: @escaping (Bool) -> Void) {
        loginManager.confirmEmail(authString: authString, deviceID: authManager.deviceID) { [weak self] (errorResponse, token) in
            guard let strongSelf = self else { return }
            if let errorType = errorResponse {
                strongSelf.error = errorType
            } else {
                strongSelf.error = nil
                strongSelf.currentPage = .emailEntry
            }
            if let tokenInfo = token {
                strongSelf.authManager.token = tokenInfo
            }
            callback(errorResponse == nil)
            strongSelf.isTransition = false
        }
    }
    
    func submitEmail(emailString: String) {
        loginManager.submitEmail(emailString: emailString) { [weak self] errorResponse in
            guard let strongSelf = self else { return }
            if let errorType = errorResponse {
                strongSelf.error = errorType
            } else {
                strongSelf.error = nil
                strongSelf.currentPage = .codeEntry
            }
            strongSelf.isTransition = false
        }
    }
    
    func buttonClicked(textInput: String, callback: @escaping (Bool) -> Void) {
        SwiftyBeaver.verbose("Button clicked, input: \(textInput)")
        switch currentPage {
        case .codeEntry, .emailEntry:
            if !isTransition && !textInput.isEmpty {
                isTransition = true
                if currentPage == .codeEntry {
                    submitAuthString(authString: textInput, callback: callback)
                } else {
                    submitEmail(emailString: textInput)
                }
            } else {
                callback(false)
            }
        case .noAccountError:
            if let url = URL(string: Constants.mainVpnURL) {
                NSWorkspace.shared.open(url)
            }
        case .subEndedError:
            if let url = URL(string: Constants.accountsURL) {
                NSWorkspace.shared.open(url)
            }
        case .deviceLimitError:
            if let url = URL(string: Constants.accountsURL) {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    func tryAgainClicked() {
        loginManager.reset()
        currentPage = .emailEntry
        error = nil
        isTransition = false
    }
    
    func dismissError() {
        error = nil
    }
    
    func checkError() {
        if errorManager.isAuthError {
            error = .loggedOut
        }
    }
}

extension LoginViewModel {
    enum LoginPages {
        case emailEntry
        case codeEntry
        case noAccountError
        case subEndedError
        case deviceLimitError
    }
    
    struct LoginStrings {
        var titleText: String
        var descriptionText: String
        var placeholderText: String?
        var buttonText: String
        var linkText: String?
        var footerText: String?
        var footerTryAgainText: String?
        var footerWebLinks: [String: String]?
    }
    
    struct ErrorStrings {
        var errorText: String
        var errorTryAgainText: String?
        var errorWebLinks: [String: String]?
    }
    
    static let emailEntryText = LoginStrings(titleText: "Sign In",
                                             descriptionText: "Enter the email address you used when you purchased AdBlock VPN:",
                                             placeholderText: "Email Address",
                                             buttonText: "Next",
                                             linkText: "<a href='\(Constants.newTicketURL)'>Forgot your email?</a>",
                                             footerText: "Don't have an AdBlock account? Sign up.",
                                             footerWebLinks: ["Sign up.": Constants.mainVpnURL])
    static let codeEntryText = LoginStrings(titleText: "Check Your Email",
                                            descriptionText: "We sent you a 6-character access code. Enter it below:",
                                            placeholderText: "— — — — — —",
                                            buttonText: "Submit",
                                            footerText: "Didn't get the code? Try again.",
                                            footerTryAgainText: "Try again.")
    static let noAccountText = LoginStrings(titleText: "Oops!",
                                            descriptionText: "We couldn’t find an account for that email address. Please click below to get started.",
                                            buttonText: "Get AdBlock VPN",
                                            footerText: "Doesn’t sound right? Try using a different email address or contact support.",
                                            footerTryAgainText: "Try again using a different email address",
                                            footerWebLinks: ["contact support": Constants.newTicketURL])
    static let subEndedText = LoginStrings(titleText: "Oops!",
                                           descriptionText: "It looks like your subscription has ended. Please click below to renew.",
                                           buttonText: "Renew Subscription",
                                           footerText: "Doesn’t sound right? Try using a different email address or contact support.",
                                           footerTryAgainText: "Try again using a different email address",
                                           footerWebLinks: ["contact support": Constants.newTicketURL])
    static let deviceLimitText = LoginStrings(titleText: "Oops!",
                                              descriptionText: "You have already registered the maximum 6 devices. Please click below to update your settings.",
                                              buttonText: "Manage Devices")
    
    static let invalidEmailErrorText = ErrorStrings(errorText: "Oops!\nWe don’t recognize that email address.\nPlease try again or contact support.",
                                                    errorTryAgainText: "try again",
                                                    errorWebLinks: ["contact support": Constants.newTicketURL])
    static let invalidCodeErrorText = ErrorStrings(errorText: "Oops!\nThat code didn’t work. Please try again.",
                                                   errorTryAgainText: "try again")
    static let genericErrorText = ErrorStrings(errorText: "Oops!\nSomething went wrong.\nPlease try again or contact support.",
                                               errorTryAgainText: "try again",
                                               errorWebLinks: ["contact support": Constants.newTicketURL])
    static let loggedOutErrorText = ErrorStrings(errorText: "You were logged out.\nPlease sign in again.\nIf the problem persists, contact our support team.",
                                                 errorTryAgainText: nil,
                                                 errorWebLinks: ["support team": Constants.newTicketURL])
}

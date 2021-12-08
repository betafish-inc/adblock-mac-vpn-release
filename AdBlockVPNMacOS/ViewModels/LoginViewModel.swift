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
    private var error: LoginError? {
        didSet {
            switch error {
            case nil:
                errorStrings = LoginViewModel.genericErrorText
                isOverlayError = false
            case .deviceLimit:
                currentPage = .deviceLimitError
                isOverlayError = false
            case .noAccount:
                currentPage = .noAccountError
                isOverlayError = false
            case .subEnded:
                currentPage = .subEndedError
                isOverlayError = false
            case .invalidEmail:
                errorStrings = LoginViewModel.invalidEmailErrorText
                isOverlayError = true
            case .invalidCode:
                errorStrings = LoginViewModel.invalidCodeErrorText
                isOverlayError = true
            case .generic:
                errorStrings = LoginViewModel.genericErrorText
                isOverlayError = true
            case .noServer:
                errorStrings = LoginViewModel.genericErrorText
                isOverlayError = true
                errorManager.setError(error: ErrorManager.ErrorObj(message: "", type: .noServer, link: nil))
            case .loggedOut:
                errorStrings = LoginViewModel.loggedOutErrorText
                isOverlayError = true
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
    @Published var isOverlayError = false
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
        var linkText: (String, String)?
        var footerText: String?
        var footerTryAgain: Bool = false
        var footerWebLink: String?
    }
    
    struct ErrorStrings {
        var errorText: String
        var errorTryAgain: Bool = false
    }
    
    static let emailEntryText =
        LoginStrings(titleText:
                        NSLocalizedString("Sign In",
                                          comment: "Title for email entry page"),
                     descriptionText:
                        NSLocalizedString("Enter the email address you used when you purchased AdBlock VPN:",
                                          comment: "Intructions for entering your email address"),
                     placeholderText:
                        NSLocalizedString("Email Address",
                                          comment: "Placeholder text in email entry box"),
                     buttonText:
                        NSLocalizedString("Next",
                                          comment: "Label for button on email entry page"),
                     linkText:
                        (NSLocalizedString("Forgot your email?",
                                           comment: "Link to create a help ticket on email entry page"),
                        Constants.newTicketURL),
                     footerText:
                        NSLocalizedString("Don't have an AdBlock account? Sign up.",
                                          comment: "Footer text on email entry page"),
                     footerWebLink: Constants.mainVpnURL)
    static let codeEntryText =
        LoginStrings(titleText:
                        NSLocalizedString("Check Your Email",
                                          comment: "Title of code entry page"),
                     descriptionText:
                        NSLocalizedString("We sent you a 6-character access code. Enter it below:",
                                          comment: "Intructions on code entry page"),
                     placeholderText:
                        NSLocalizedString("— — — — — —",
                                          comment: "Placeholder text in code entry box"),
                     buttonText:
                        NSLocalizedString("Submit",
                                          comment: "Label for button on code entry page"),
                     footerText:
                        NSLocalizedString("Didn't get the code? Try again.",
                                          comment: "Footer text on code entry page"),
                     footerTryAgain: true)
    static let noAccountText =
        LoginStrings(titleText:
                        NSLocalizedString("Oops!",
                                          comment: "Title of no account error page"),
                     descriptionText:
                        NSLocalizedString("We couldn’t find an account for that email address. Please click below to get started.",
                                          comment: "Intructions for no account error page"),
                     buttonText:
                        NSLocalizedString("Get AdBlock VPN",
                                          comment: "Label for button on no account error page. Links to page to set up account"),
                     footerText:
                        NSLocalizedString("Doesn’t sound right? Try using a different email address.",
                                          comment: "Footer text on no account error page"),
                     footerTryAgain: true)
    static let subEndedText =
        LoginStrings(titleText:
                        NSLocalizedString("Oops!",
                                          comment: "Title for subscription ended error page"),
                     descriptionText:
                        NSLocalizedString("It looks like your subscription has ended. Please click below to renew.",
                                          comment: "Instructions on subscription ended error page"),
                     buttonText:
                        NSLocalizedString("Renew Subscription",
                                          comment: "Label for button on subscription ended error page. Links to page where user can renew their subscription"),
                     footerText:
                        NSLocalizedString("Doesn’t sound right? Try using a different email address.",
                                          comment: "Footer text on subscription ended page"),
                     footerTryAgain: true)
    static let deviceLimitText =
        LoginStrings(titleText:
                        NSLocalizedString("Oops!",
                                          comment: "Title for device limit error page"),
                     descriptionText:
                        NSLocalizedString("You have already registered the maximum 6 devices. Please click below to update your settings.",
                                          comment: "Intructions for device limit error page"),
                     buttonText:
                        NSLocalizedString("Manage Devices",
                                          comment: "Label for button on device limit error page"))
    
    static let invalidEmailErrorText =
        ErrorStrings(errorText:
                        NSLocalizedString("We don’t recognize that email address. Please try again.",
                                          comment: "Error text for imvalid email error."),
                     errorTryAgain: true)
    static let invalidCodeErrorText =
        ErrorStrings(errorText:
                        NSLocalizedString("That code didn’t work. Please try again.",
                                          comment: "Error text for invalid code error"),
                     errorTryAgain: true)
    static let genericErrorText =
        ErrorStrings(errorText:
                        NSLocalizedString("Something went wrong. Please try again.",
                                          comment: "Error text for generic errors"),
                     errorTryAgain: true)
    static let loggedOutErrorText =
        ErrorStrings(errorText:
                        NSLocalizedString("You were logged out. Please sign in again.",
                                          comment: "Error text for loggeed out error"))
}

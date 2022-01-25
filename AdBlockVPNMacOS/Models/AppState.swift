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

enum VPNViews {
    case acceptance
    case setUpExtension
    case landing
    case login
    case setUpVPN
    case connection
    case preferences
    case account
    case help
    case contactSupportStepOne
    case contactSupportStepTwo
    case locations
    case error
    case appSettings
    case updates
    case updateError
    case updateRequired
}

class AppState: ObservableObject {
    @Published var viewToShow: VPNViews = .connection {
        didSet {
            if ![.help, .contactSupportStepOne, .contactSupportStepTwo, .account, .preferences, .appSettings, .updates, .updateError, .updateRequired].contains(oldValue) {
                previousView = oldValue
            }
        }
    }
    var previousView: VPNViews = .connection
    var eulaAccepted = UserDefaults.standard.bool(forKey: Constants.acceptance_key) {
        didSet {
            UserDefaults.standard.set(eulaAccepted, forKey: Constants.acceptance_key)
        }
    }

    @Published var showConnectionInfo = UserDefaults.standard.bool(forKey: Constants.showConnectionInfo_key) {
        didSet {
            UserDefaults.standard.set(showConnectionInfo, forKey: Constants.showConnectionInfo_key)
        }
    }

    @Published var sysExtensionActive = false {
        didSet {
            if sysExtensionActive == true && viewToShow == .setUpExtension {
                viewToShow = .acceptance
            }
        }
    }
    @Published var vpnProfileActive = false {
        didSet {
            if vpnProfileActive == true && viewToShow == .setUpVPN {
                viewToShow = .connection
            }
        }
    }
    @Published var restartConnection = false
    @Published var providerAuthChecked = false
    @Published var showOverlay = false
    var versionString: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "x.x.x"
    }
    var contactSupportStepOneSkipped = false
    
    func getViewTitle() -> String {
        switch viewToShow {
        case .preferences:
            return NSLocalizedString("Preferences", comment: "Preferences page title")
        case .account:
            return NSLocalizedString("Account", comment: "Account page title")
        case .help:
            return NSLocalizedString("Help & Feedback", comment: "Help and feedback page title")
        case .contactSupportStepOne, .contactSupportStepTwo:
            return NSLocalizedString("Contact Support", comment: "Contact Support page title")
        case .locations:
            return NSLocalizedString("Choose location", comment: "Location picker page title")
        case .appSettings:
            return NSLocalizedString("App Settings", comment: "App settings page title")
        default:
            return ""
        }
    }
    
    func backButtonClick() {
        switch viewToShow {
        case .preferences:
            viewToShow = previousView
        case .account, .help, .appSettings:
            viewToShow = .preferences
        case .locations, .updates, .updateError:
            viewToShow = .connection
        case .contactSupportStepOne:
            viewToShow = .help
        case .contactSupportStepTwo:
            viewToShow = contactSupportStepOneSkipped ? .help : .contactSupportStepOne
            contactSupportStepOneSkipped = false
        default:
            fatalError()
        }
    }
    
    func checkViewToShow(loggedIn: Bool, isError: Bool, updateRequired: Bool) {
        if [.preferences, .account, .help, .contactSupportStepOne, .contactSupportStepTwo, .appSettings, .updates, .updateError, .updateRequired, .locations]
            .contains(viewToShow) {
            return
        }
        if updateRequired {
            viewToShow = .updateRequired
            return
        } else if !sysExtensionActive {
            viewToShow = .setUpExtension
        } else if !eulaAccepted {
            viewToShow = .acceptance
        } else if !loggedIn && [.acceptance, .setUpExtension, .landing].contains(viewToShow) {
            viewToShow = .landing
        } else if isError {
            viewToShow = .error
        } else if !loggedIn {
            viewToShow = .login
        } else {
            viewToShow = .connection
        }
        
        if !vpnProfileActive && viewToShow == .connection {
            viewToShow = .setUpVPN
        }
    }
}

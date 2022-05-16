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

import Cocoa
import SwiftyBeaver

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
    case themeSettings
    case updates
    case updateError
    case updateRequired
}

enum GUIScaleFactor: String {
    case zoomOut3
    case zoomOut2
    case zoomOut1
    case actualSize
    case zoomIn1
    case zoomIn2
    case zoomin3

    /// The scale factor for both the App and Textfield.
    /// A scaled TextField normally has errors, so we migitate
    /// this by offsetting the scale factor.
    var scale: (app: Double, textField: Double, textFieldFontSize: CGFloat) {
        // swiftlint:disable:previous large_tuple
        switch self {
        case .zoomOut3:
            return(0.7, 1.4286, 13)
        case .zoomOut2:
            return(0.8, 1.25, 14)
        case .zoomOut1:
            return(0.9, 1.11, 15)
        case .actualSize:
            return(1, 1, 16)
        case .zoomIn1:
            return(1.1, 0.909, 17)
        case .zoomIn2:
            return(1.2, 0.8334, 18)
        case .zoomin3:
            return(1.3, 0.7692, 19)
        }
    }
}

enum SystemTheme: String {
    case system
    case light
    case dark
}

class AppState: ObservableObject {
    @Published var viewToShow: VPNViews = .connection {
        didSet {
            if ![
                .help,
                .contactSupportStepOne,
                .contactSupportStepTwo,
                .account,
                .preferences,
                .appSettings,
                .themeSettings,
                .updates,
                .updateError,
                .updateRequired
            ].contains(oldValue) {
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
            // If showConnectionInfo is set to true, trigger a refresh of IP Addresses
            if showConnectionInfo {
                NotificationCenter.default.post(name: Constants.connectionSatisfiedNotification, object: nil)
            }
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

    @Published var guiScaleFactor = GUIScaleFactor(rawValue: UserDefaults.standard.string(forKey: Constants.guiScaleFactor_key) ?? "actualSize") ?? .actualSize {
        didSet {
            SwiftyBeaver.debug("App scale changed to \(guiScaleFactor)")
            UserDefaults.standard.set(guiScaleFactor.rawValue, forKey: Constants.guiScaleFactor_key)
            UserDefaults.standard.set(guiScaleFactor.scale.textFieldFontSize, forKey: Constants.guiTextFieldFontSize_key)
        }
    }

    @Published var currentTheme = SystemTheme(rawValue: UserDefaults.standard.string(forKey: Constants.selectedTheme_key) ?? "system") ?? .system {
        didSet {
            SwiftyBeaver.debug("App theme changed to \(currentTheme)")
            UserDefaults.standard.set(currentTheme.rawValue, forKey: Constants.selectedTheme_key)
            setOnboardingTitlebarColor()
        }
    }

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
        case .themeSettings:
            return NSLocalizedString("Theme", comment: "Theme settings page title")
        default:
            return ""
        }
    }
    
    func backButtonClick() {
        switch viewToShow {
        case .preferences:
            viewToShow = previousView
        case .account, .help, .appSettings, .themeSettings:
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
        if [.preferences, .account, .help, .contactSupportStepOne, .contactSupportStepTwo, .appSettings, .themeSettings, .updates, .updateError, .updateRequired, .locations]
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

    func guiZoomIn() {
        switch guiScaleFactor {
        case .zoomOut3:
            guiScaleFactor = .zoomOut2
        case .zoomOut2:
            guiScaleFactor = .zoomOut1
        case .zoomOut1:
            guiScaleFactor = .actualSize
        case .actualSize:
            guiScaleFactor = .zoomIn1
        case .zoomIn1:
            guiScaleFactor = .zoomIn2
        case .zoomIn2:
            guiScaleFactor = .zoomin3
        case .zoomin3:
            return
        }
        resetWindowSizes()
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.popover.contentSize = NSSize(width: 320 * guiScaleFactor.scale.app, height: 440)
    }

    func guiZoomOut() {
        switch guiScaleFactor {
        case .zoomOut3:
            return
        case .zoomOut2:
            guiScaleFactor = .zoomOut3
        case .zoomOut1:
            guiScaleFactor = .zoomOut2
        case .actualSize:
            guiScaleFactor = .zoomOut1
        case .zoomIn1:
            guiScaleFactor = .actualSize
        case .zoomIn2:
            guiScaleFactor = .zoomIn1
        case .zoomin3:
            guiScaleFactor = .zoomIn2
        }
        resetWindowSizes()
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.popover.contentSize = NSSize(width: 320 * guiScaleFactor.scale.app, height: 440)
    }

    func guiResetView() {
        guard guiScaleFactor != .actualSize else { return }
        guiScaleFactor = .actualSize
        resetWindowSizes()
    }

    private func resetWindowSizes() {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.popover.contentSize = NSSize(width: 320 * guiScaleFactor.scale.app, height: 440)
        appDelegate.onboardingWindow?.center()
    }

    private func setOnboardingTitlebarColor() {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return }
        switch currentTheme {
        case .system:
            appDelegate.onboardingWindow?.backgroundColor = .abBackground
        case .light:
            appDelegate.onboardingWindow?.backgroundColor = .abOnboardingTitlebarLight
        case .dark:
            appDelegate.onboardingWindow?.backgroundColor = .abOnboardingTitlebarDark
        }
    }
}

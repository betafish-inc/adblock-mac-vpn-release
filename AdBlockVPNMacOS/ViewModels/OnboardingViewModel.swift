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
import NetworkExtension
import SwiftyBeaver
import UserNotifications

class OnboardingViewModel: ObservableObject {
    @Published var viewToShow: OnboardingViews
    @Published var sysExtensionActive = false
    @Published var vpnProfileActive = false
    @Published var notificationInstructions: OnboardingNotificationInstructions = .alert
    @Published var notificationAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    private let vpnManager: VPNManager
    private let notificationManager: NotificationManager

    init(viewToShow: OnboardingViews = .intro, vpnManager: VPNManager, notificationManager: NotificationManager) {
        self.viewToShow = viewToShow
        self.vpnManager = vpnManager
        self.notificationManager = notificationManager
        self.checkVPNConfigState()
        self.checkUserNotificationsAuthorizationState()
    }

    func checkViewToShow() {
        if sysExtensionActive == false {
            self.viewToShow = .sysExtension
        } else if vpnProfileActive == false {
            self.viewToShow = .VPNConfig
            // As notifications are an optional stage of onboarding, we can progress the view flow if user opts to skip this step.
        } else if notificationAuthorizationStatus != .authorized && viewToShow != .notifications {
            self.viewToShow = .notifications
        } else {
            self.viewToShow = .complete
        }
    }

    /// Attempts to install a blank VPN profile for the purpose of presenting the `Add VPN Configuration` modal popup.
    func installVPNProfile() {
        vpnManager.configureVPN(selectedGeo: nil, deviceID: "", tokenInfo: TokenInfo(accessToken: "", tokenType: "", expiresIn: 0, refreshToken: "")) { response in
            self.vpnProfileActive = response
            SwiftyBeaver.verbose("Onboarding VPN profile installed: \(response)")
        }
    }

    /// Opens System Preferences `Security` page.
    func openSecurityPreferences() {
        NSWorkspace.shared.open(URL(fileURLWithPath: Constants.securityPrefsPaneURL))
    }

    /// Opens System Preferences `Notifications` page.
    func openNotifications() {
        switch notificationInstructions {
        case .alert:
            notificationManager.requestAuth()
        case .systemPreferences:
            NSWorkspace.shared.open(URL(fileURLWithPath: Constants.notificationsPrefsPaneURL))
        }
    }

    /// Opens AdBlock support website.
    func openSupportURL() {
        if let url = URL(string: Constants.permissionsHelpURL) {
            NSWorkspace.shared.open(url)
        }
    }

    /// Checks if user notifications are enabled, and sets `@Published var notificationAuthorizationStatus` based on the result.
    func checkUserNotificationsAuthorizationState() {
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings(completionHandler: { (settings) in
            DispatchQueue.main.async {
                self.notificationAuthorizationStatus = settings.authorizationStatus
                if settings.authorizationStatus == .denied { self.notificationInstructions = .systemPreferences }
            }
        })
    }

    /// Dismisses onboarding window, sets statusBarItem to visible and conditionally shows the popover UI.
    /// - Parameter showPopover: A Boolean value to indicate if the popover UI should display.
    func completeOnboarding(showPopover: Bool = true) {
        guard let appDelegate: AppDelegate = NSApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.setStatusBarItemVisibility(isVisible: true)
        if showPopover {
            appDelegate.showPopover(nil)
        }
    }

    /// Checks if VPN profile has been accepted by the user.
    fileprivate func checkVPNConfigState() {
        self.vpnManager.initializeProviderManager { vpnProfileAllowed in
            self.vpnProfileActive = vpnProfileAllowed
        }
    }
}

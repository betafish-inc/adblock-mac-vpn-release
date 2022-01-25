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

public struct Constants {
    static let channelName = "alpha"
    
    static let tunnelProviderID = "com.adblockinc.adblockvpn.macos.provider"
    static let keychainID = Bundle.main.bundleIdentifier ?? "com.adblockinc.adblockvpn.macos"
    static let deviceID_key = "deviceID"
    static let refreshToken_key = "refreshToken"
    static let loggedOut_key = "loggedOutDate"
    static let acceptance_key = "eulaAccepted"
    static let reconnect_key = "reconnectVPN"
    static let geo_key = "geoKey"
    static let pingDate_key = "pingDateKey"
    static let modifiedDate_key = "modifiedDate"
    static let willInstallUpdate_key = "willInstallUpdate"
    static let onboardingCompleted_key = "onboardingCompleted"
    static let autoUpdate_key = "autoUpdate"
    static let showDockIcon_key = "showDockIcon"
    static let launchAtLoginSet_key = "launchAtLoginSet"
    static let lastError_key = "lastError"
    static let showConnectionInfo_key = "showConnectionInfo"

    // Path suffixes for log files.
    static let appLogFilePath = "AdBlock VPN/AdBlockVPNApp.log"
    static let appLogFileReadmePath = "AdBlock VPN/README.txt"
    static let providerLogFilePath = "AdBlock VPN Provider/AdBlockVPNProvider.log"
    static let LogFilesArchiveFilename = "AdBlockVPNLogs.zip"
    
    static let helpURL = "http://vpnsupport.getadblock.com/"
    static let newTicketURL = "https://vpnsupport.getadblock.com/support/tickets/new"
    static let needMachineRestartURL = "https://vpnsupport.getadblock.com/support/solutions/articles/6000247634-how-to-install-uninstall-and-reinstall-adblock-vpn"
    static let connectionHelpURL = "https://vpnsupport.getadblock.com/support/solutions/articles/6000247858-adblock-vpn-connection-issues/"
    static let permissionsHelpURL = "https://vpnsupport.getadblock.com/support/solutions/articles/6000249111-about-adblock-vpn-permissions-for-mac"
    
    static let feedbackURL = "https://vpn.getadblock.com/feedback"
    static let accountsURL = "https://accounts.getadblock.com"
    static let eulaURL = "https://vpn.getadblock.com/end-user-license-agreement/"
    static let privacyURL = "https://getadblock.com/privacy/"
    static let mainVpnURL = "https://vpn.getadblock.com/"
    static let macDownloadsURL = "https://vpn.getadblock.com/mac/"
    static let logsPrivacyInfoKBArticleURL = "https://vpnsupport.getadblock.com/support/solutions/articles/6000240495-about-privacy-and-tracking-in-adblock-vpn"
    static let provideLogsKBArticleURL = "https://vpnsupport.getadblock.com/support/solutions/articles/6000247633-how-to-provide-your-adblock-vpn-logs"
    
    static let refreshURL = "https://api.adblock.dev/v1/vpn/oauth/token"
    static let logOutURL = "https://api.adblock.dev/v1/vpn/logout"
    static let regionsURL = "https://api.adblock.dev/v1/regions"
    static let emailURL = "https://api.adblock.dev/v1/vpn/login/email"
    static let confirmURL = "https://api.adblock.dev/v1/vpn/login/email/confirm"
    static let logURL = "https://log.adblock.dev/v2/record_log"
    static let accountsMagicLoginURL = "https://api.adblock.dev/v1/vpn/token/account"
    static let ipv4ConnectionInfoURL = "https://ip4.adblock.dev"
    static let ipv6ConnectionInfoURL = "https://ip6.adblock.dev"

    static let securityPrefsPaneURL = "/System/Library/PreferencePanes/Security.prefPane"
    static let notificationsPrefsPaneURL = "/System/Library/PreferencePanes/Notifications.prefPane"

    static let connectionSatisfiedNotification = NSNotification.Name(rawValue: "connectionSatisfied")
}

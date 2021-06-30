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
import Sparkle
import SwiftyBeaver

class UpdateManager: NSObject {
    @Published var updateAvailable = false
    @Published var updateFailed = false
    @Published var updateIsRequired = false
    var logManager: LogManager
    var updateVersion = ""
    var applyUpdatesAutomatically = true {
        didSet {
            UserDefaults.standard.setValue(applyUpdatesAutomatically, forKey: Constants.autoUpdate_key)
            SUUpdater.shared()?.automaticallyDownloadsUpdates = applyUpdatesAutomatically
        }
    }
    private var defaults = UserDefaults.standard
    var storedUpdateBlock: (() -> Void)?
    var isUserInitiated = false
    
    init(logManager: LogManager) {
        self.logManager = logManager
        if defaults.object(forKey: Constants.autoUpdate_key) != nil {
            applyUpdatesAutomatically = defaults.bool(forKey: Constants.autoUpdate_key)
        } else {
            applyUpdatesAutomatically = true
        }
    }
    
    func checkForUpdates() {
        SUUpdater.shared()?.checkForUpdateInformation()
    }
    
    func checkForUpdatesInBackground() {
        SUUpdater.shared()?.checkForUpdatesInBackground()
    }
    
    func update() {
        SUUpdater.shared()?.checkForUpdates(self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

extension UpdateManager: SUUpdaterDelegate {
    func updater(_ updater: SUUpdater, didFindValidUpdate item: SUAppcastItem) {
        updateVersion = item.displayVersionString
        updateAvailable = true
        updateIsRequired = item.isCriticalUpdate
    }
    
    func updaterDidNotFindUpdate(_ updater: SUUpdater) {
        updateAvailable = false
        updateIsRequired = false
    }
    
    func updater(_ updater: SUUpdater, willInstallUpdate item: SUAppcastItem) {
        logManager.sendLogMessage(message: .update, target: item.versionString)
        defaults.setValue(true, forKey: Constants.willInstallUpdate_key)
    }
    
    func updater(_ updater: SUUpdater, didAbortWithError error: Error) {
        SwiftyBeaver.verbose("update error: \(error.localizedDescription)")
        let err = error as NSError
        if isUserInitiated && err.code != 1001 {
            updateFailed = true
        }
        isUserInitiated = false
    }
    
    func updater(_ updater: SUUpdater, willInstallUpdateOnQuit item: SUAppcastItem, immediateInstallationBlock installationBlock: @escaping () -> Void) {
        SwiftyBeaver.verbose("willInstallUpdateOnQuit")
        storedUpdateBlock = installationBlock
    }
}

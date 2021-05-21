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
import Sparkle

class UpdateManager: NSObject {
    @Published var updateAvailable = false
    var logManager: LogManager
    var updateVersion = ""
    var applyUpdatesAutomatically = true {
        didSet {
            UserDefaults.standard.setValue(applyUpdatesAutomatically, forKey: Constants.autoUpdate_key)
            SUUpdater.shared()?.automaticallyDownloadsUpdates = applyUpdatesAutomatically
        }
    }
    private var defaults = UserDefaults.standard
    
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
    
    func update() {
        SUUpdater.shared()?.checkForUpdates(self)
    }
}

extension UpdateManager: SUUpdaterDelegate {
    func updater(_ updater: SUUpdater, didFindValidUpdate item: SUAppcastItem) {
        updateVersion = item.displayVersionString
        updateAvailable = true
    }
    
    func updaterDidNotFindUpdate(_ updater: SUUpdater) {
        updateAvailable = false
    }
    
    func updater(_ updater: SUUpdater, willInstallUpdate item: SUAppcastItem) {
        logManager.sendLogMessage(message: .update, target: item.versionString)
        defaults.setValue(true, forKey: Constants.willInstallUpdate_key)
    }
}

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
import Combine

class AppSettingsViewModel: ObservableObject {
    private var updateManager: UpdateManager
    private var dockIconManager: DockIconManager
    private var cancellable: AnyCancellable?
    @Published var showDockIcon: Bool
    @Published var updateAvailable = false
    @Published var automaticUpdatesOn = true {
        didSet {
            updateManager.applyUpdatesAutomatically = automaticUpdatesOn
        }
    }
    
    init(updateManager: UpdateManager, dockIconManager: DockIconManager) {
        self.updateManager = updateManager
        self.dockIconManager = dockIconManager
        self.showDockIcon = dockIconManager.dockIconIsVisible
        automaticUpdatesOn = updateManager.applyUpdatesAutomatically
        registerForUpdateAvailability()
    }
    
    func registerForUpdateAvailability() {
        cancellable = updateManager.$updateAvailable.sink { available in
            self.updateAvailable = available
        }
    }
    
    func checkForUpdates() {
        updateManager.checkForUpdates()
    }

    /// Updates the activation policy of the host app to either show or hide the dock icon, and persists this information in UserDefaults.
    /// - Parameter isVisible: A boolean value that represents if the dock should be visible or not.
    func setDockIconVisibility(isVisible: Bool) {
        dockIconManager.setDockIconVisibility(isVisible: isVisible)
    }
}

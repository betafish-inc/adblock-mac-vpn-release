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

class DockIconManager {
    private let defaults = UserDefaults.standard
    /// A Bool value of the dock icon's current visibility state.
    var dockIconIsVisible: Bool

    init() {
        // Using `Object(forKey:)` here as it returns nil if no key is set, rather than `Bool(forKey:)` which'll return false.
        // If nil, we can assume the user has not yet set a preference, so we can continue with the default value of `true`.
        self.dockIconIsVisible = defaults.object(forKey: Constants.showDockIcon_key) as? Bool ?? true
    }

    /// Sets the dock icon visibility as per the preference set in UserDefaults. If no preference is found, the dock icon will be shown.
    /// To be called on prior to app launch in the `applicationWillFinishLaunching` function.
    func setDockIconVisibilityOnAppLaunch() {
        setDockIconVisibility(isVisible: self.dockIconIsVisible)
    }

    /// Updates the activation policy of the host app to either show or hide the dock icon, and persists this information in UserDefaults.
    /// - Parameter isVisible: A boolean value that represents if the dock should be visible or not.
    func setDockIconVisibility(isVisible: Bool) {
        defaults.setValue(isVisible, forKey: Constants.showDockIcon_key)
        self.dockIconIsVisible = isVisible
        switch isVisible {
        case true:
            NSApp.setActivationPolicy(.regular)
        case false:
            NSApp.setActivationPolicy(.accessory)
        }
    }
}

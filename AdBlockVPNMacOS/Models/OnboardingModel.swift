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

// As the cases conform to Int, the order in which they are declared matters,
// and should reflect the desired order on the onboarding flow.
enum OnboardingViews: Int, Comparable, CaseIterable {
    case intro
    case sysExtension
    case sysExtensionError
    case VPNConfig
    case VPNConfigError
    case notifications
    case complete
    case appMove

    static func < (lhs: OnboardingViews, rhs: OnboardingViews) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

enum OnboardingNotificationInstructions {
    case alert
    case systemPreferences
}

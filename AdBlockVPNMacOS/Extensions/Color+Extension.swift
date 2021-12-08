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

import SwiftUI

// Asset Catalog custom colors
extension Color {
    // Text colors
    static let abDarkText = Color("abGray33")
    static let abLightText = Color("abGray66")
    static let abLightestText = Color("abGray99")
    static let abWhiteText = Color("abWhite")
    static let abLinkColor = Color("abBlueLight")

    // Button colors
    static let abButtonNormal = Color("abBlue")
    static let abButtonHover = Color("abBlueLight")
    static let abButtonClick = Color("abBlueDark")
    static let abSecondaryButtonNormal = Color("abWhite")
    static let abSecondaryButtonClick = Color("abGrayC6")
    static let abDisabledButtonForeground = Color("abWhite")
    static let abDisabledButtonBackground = Color("abGrayC6")
    static let abToggleOn = Color("abGreen")
    static let abToggleOff = Color("abGrayC6")
    static let abToggleCircle = Color("abWhite")
    static let abUpToDateAccent = Color("abGreen")
    static let abUpdateAccent = Color("abYellow")
    static let abUpdateAccentClick = Color("abOrange")
    static let abErrorAccent = Color("abRed")
    static let abErrorDismiss = Color("abWhite")

    // VPN state colors
    static let abVPNStateConnected = Color("abGreen")
    static let abVPNStateConnecting = Color("abOrange")
    static let abVPNStateDisconnected = Color("abRed")

    // Region list colors
    static let abListItemClicked = Color("abGrayE6")
    static let abSearchBarBackground = Color("abWhite")
    static let abListItemBackground = Color("abWhite")

    // General UI Colors
    static let abBackground = Color("abWhite")
    static let abAccentBackground = Color("abGrayE6")
    static let abHeaderBackground = Color("abGrayF4")
    static let abSecondaryHeaderBackground = Color("abGrayE6")
    static let abBorder = Color("abGrayC6")
    static let abPrimaryAccent = Color("abBlue")
    static let abShadow = Color("abGrayTransparent")
    static let abShadowLight = Color("abWhite")
    static let abInactiveAccent = Color("abGray99")
}

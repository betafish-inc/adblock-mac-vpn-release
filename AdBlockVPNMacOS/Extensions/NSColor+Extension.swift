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

// Asset Catalog custom colors
extension NSColor {
    // Text colors
    static let abDarkText = NSColor(named: "abGray33") ?? .black
    static let abWhiteText = NSColor(named: "abWhite") ?? .white
    static let abLightText = NSColor(named: "abGray66") ?? .lightGray
    static let abLightestText = NSColor(named: "abGray99") ?? .lightGray
    static let abLinkColor = NSColor(named: "abBlueLight") ?? .blue

    // General UI colors
    static let abBackground = NSColor(named: "abWhite") ?? .white
    static let abHeaderBackground = NSColor(named: "abGrayF4") ?? .white
    static let abPrimaryAccent = NSColor(named: "abBlue") ?? .blue
    static let abErrorAccent = NSColor(named: "abRed") ?? .red
}

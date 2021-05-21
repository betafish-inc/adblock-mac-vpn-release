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

import Cocoa

extension NSFont {
    private static func customFont(weight: CustomFontWeight, size: CGFloat) -> NSFont {
        let font = NSFont(name: weight.rawValue, size: size)
        return font ?? NSFont.systemFont(ofSize: size)
    }

    /// Creates an NSFont for the Lato font family.
    /// - Parameters:
    ///   - weight: Sets the weight of the font. The default value is `.regular` if not specified.
    ///   - size: Sets the size of the font. The default value is `16` if not specified.
    /// - Returns: An NSFont modified to Lato with the specified `weight` & `size` specified
    static func latoFont(weight: CustomFontWeight = .regular, size: CGFloat = 16) -> NSFont {
        return customFont(weight: weight, size: size)
    }

    enum CustomFontWeight: String {
        case regular = "Lato-Regular"
        case bold = "Lato-Bold"
    }
}

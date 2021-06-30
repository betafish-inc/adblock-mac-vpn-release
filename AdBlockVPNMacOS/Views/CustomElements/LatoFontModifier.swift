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

private struct LatoFontModifier: ViewModifier {
    var weight: Font.Weight
    var size: CGFloat

    func body(content: Content) -> some View {
        content
            .font(Font.custom("Lato-Regular", size: size).weight(weight))
    }
}

extension View {
    /// Modifies the input view text to the Lato font family.
    /// - Parameters:
    ///   - weight: Sets the weight of the font. The default value is `.regular` if not specified.
    ///   - size: Sets the size of the font. The default value is `16` if not specified.
    /// - Returns: A view with the text font modified to Lato with the specified `weight` & `size` specified
    func latoFont(weight: Font.Weight = .regular, size: CGFloat = 16) -> some View {
        self.modifier(LatoFontModifier(weight: weight, size: size))
    }
}

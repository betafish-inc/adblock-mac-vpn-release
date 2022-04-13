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

struct TopBarButtonStyle: ButtonStyle {
    @State private var isHover = false
    private var animationSpeed: Double = 0.15

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? .abButtonClick : isHover ? .abButtonNormal : .abDarkText)
            .shadow(color: configuration.isPressed ? .clear : .abShadow,
                    radius: isHover ? 4 : 0,
                    x: 0,
                    y: isHover ? 4 : 0)
            .onHover { inside in
                withAccessibilityFriendlyAnimation(.easeInOut(duration: animationSpeed)) {
                    isHover = inside
                }
            }
    }
}

struct TopBarButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            Button(action: {}, label: {
                Image("BackArrowIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 18.76)
            })
            .buttonStyle(TopBarButtonStyle())
            Button(action: {}, label: {
                Image("MenuIcon")
            })
            .buttonStyle(TopBarButtonStyle())
        }
        .padding()
    }
}

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

struct PrimaryButtonStyle: ButtonStyle {
    @State private var isHover = false
    private var labelHoverOffset: CGFloat {
        NSWorkspace.shared.accessibilityDisplayShouldReduceMotion ? 0 : -1
    }
    var buttonColor: Color = .abButtonNormal
    var buttonHoverColor: Color = .abButtonHover
    var buttonClickColor: Color = .abButtonClick
    var textColor: Color = .abButtonForeground
    var shadowColor: Color = .abShadow
    var buttonWidth: CGFloat = 272
    var animationSpeed: Double = 0.15
    var enableAnimation: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .offset(x: 0, y: configuration.isPressed ? 0 : isHover && enableAnimation ? labelHoverOffset : 0)
            .multilineTextAlignment(.center)
            .padding(8)
            .frame(maxWidth: buttonWidth, minHeight: 40, idealHeight: 40)
            .background(configuration.isPressed ? buttonClickColor : isHover ? buttonHoverColor : buttonColor)
            .foregroundColor(textColor)
            .cornerRadius(6)
            .shadow(color: configuration.isPressed ? .clear : shadowColor,
                    radius: isHover ? 4 : 0,
                    x: 0,
                    y: isHover ? 4 : 0)
            .latoFont(weight: .bold)
            .onHover { inside in
                withAccessibilityFriendlyAnimation(.easeInOut(duration: animationSpeed)) { isHover = inside }
            }
    }
}

struct PrimaryButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            Button(action: {}, label: { Text(verbatim: "Button") })
                .buttonStyle(PrimaryButtonStyle())
            Button(action: {}, label: { Text(verbatim: "A lot of text to intentionally make the button two lines") })
                .buttonStyle(PrimaryButtonStyle())
            Button(action: {}, label: { Text(verbatim: "Custom Style") })
                .buttonStyle(PrimaryButtonStyle(buttonColor: Color.black.opacity(0.9), textColor: .pink, buttonWidth: 150))
        }
        .padding()
    }
}

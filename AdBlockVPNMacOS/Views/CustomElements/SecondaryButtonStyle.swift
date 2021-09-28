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

struct SecondaryButtonStyle: ButtonStyle {
    @State private var isHover = false
    var buttonWidth: CGFloat = 272
    var icon: String = ""
    var bold: Bool = true
    var buttonColor: Color = .abSecondaryButtonNormal
    var buttonClickColor: Color = .abSecondaryButtonClick
    var borderColor: Color = .abBorder
    var textColor: Color = .abDarkText
    var iconColor: Color = .abDarkText
    var animationSpeed: Double = 0.15

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            configuration.label
                // CGFloat() explicitly added to fix bug in SwiftUI Previews
                // Extra horizontal padding prevents ZStack clipping with icon
                .padding(.horizontal, icon.isEmpty ? 0 : CGFloat(32))
                .offset(x: 0, y: configuration.isPressed ? 0 : isHover ? -1 : 0)
                .multilineTextAlignment(.center)
                .padding(8)
                .frame(maxWidth: buttonWidth, minHeight: 40, idealHeight: 40)
                .background(configuration.isPressed ? buttonClickColor : buttonColor)
                .foregroundColor(textColor)
                .cornerRadius(6)
                .shadow(color: configuration.isPressed ? .clear : .abShadow,
                        radius: isHover ? 4 : 0,
                        x: 0,
                        y: isHover ? 4 : 0)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(borderColor, lineWidth: 1))
                .latoFont(weight: bold ? .bold : .regular)
            if !icon.isEmpty {
                Image(icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 13)
                    .foregroundColor(iconColor)
                    .offset(x: CGFloat((buttonWidth / 2) - 22), y: isHover ? -1 : 0)
            }
        }
        .onHover { inside in
            withAnimation(.easeInOut(duration: animationSpeed)) { isHover = inside }
        }
    }
}

struct SecondaryButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            Button(action: {}, label: { Text(verbatim: "Button") })
                .buttonStyle(SecondaryButtonStyle())
            Button(action: {}, label: { Text(verbatim: "Button with Icon") })
                .buttonStyle(SecondaryButtonStyle(icon: "NextIcon"))
            Button(action: {}, label: { Text(verbatim: "Button with Icon and a lot of non-bold text") })
                .buttonStyle(SecondaryButtonStyle(icon: "NextIcon", bold: false))
            Button(action: {}, label: { Text(verbatim: "Custom Style") })
                .buttonStyle(SecondaryButtonStyle(buttonWidth: 200,
                                                  icon: "NextIcon",
                                                  bold: false,
                                                  buttonColor: Color.black.opacity(0.9),
                                                  borderColor: .pink,
                                                  textColor: .white,
                                                  iconColor: .pink))
        }
        .padding()
    }
}

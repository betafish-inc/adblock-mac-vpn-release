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

struct DisabledButtonStyle: ButtonStyle {
    @State private var isHover = false
    var buttonColor: Color = .abBorder
    var textColor: Color = .abDisabledButtonForeground
    var buttonWidth: CGFloat = 272

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .multilineTextAlignment(.center)
            .padding(8)
            .frame(maxWidth: buttonWidth, minHeight: 40, idealHeight: 40)
            .background(buttonColor)
            .foregroundColor(textColor)
            .cornerRadius(6)
            .latoFont(weight: .bold)
            .disabled(true)
    }
}

struct DisabledButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            Button(action: {}, label: { Text(verbatim: "Button") })
                .buttonStyle(DisabledButtonStyle())
            Button(action: {}, label: { Text(verbatim: "A lot of text to intentionally make the button two lines") })
                .buttonStyle(DisabledButtonStyle())
            Button(action: {}, label: { Text(verbatim: "Custom Style") })
                .buttonStyle(DisabledButtonStyle(buttonColor: Color.black.opacity(0.9), textColor: .pink, buttonWidth: 150))
        }
        .padding()
    }
}

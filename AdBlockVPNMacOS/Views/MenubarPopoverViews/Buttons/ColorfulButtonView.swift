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

struct ColorfulButtonView: View {
    var action: (() -> Void)?
    var text: Text
    var icon: String
    var iconSize: Int
    var updateAvailable: Bool
    var body: some View {
        Button(action: action ?? {}, label: {
            HStack {
                Spacer().frame(width: 16)
                text
                    .latoFont()
                Spacer()
                if !icon.isEmpty {
                    Image(decorative: icon)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(height: CGFloat(iconSize))
                }
                Spacer().frame(width: 14)
            }
        })
        .buttonStyle(PrimaryButtonStyle(buttonColor: updateAvailable ? .abUpdateAccent : .abUpToDateAccent,
                                        buttonHoverColor: updateAvailable ? .abUpdateAccent : .abUpToDateAccent,
                                        buttonClickColor: updateAvailable ? .abUpdateAccentClick : .abUpToDateAccent,
                                        textColor: updateAvailable ? .abDarkText : .abWhiteText,
                                        shadowColor: updateAvailable ? .abShadow : .clear,
                                        enableAnimation: updateAvailable))
    }
}

struct ColorfulButtonView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
        ColorfulButtonView(action: nil,
                           text: Text(verbatim: "Update Available"),
                           icon: "NextIcon",
                           iconSize: 11,
                           updateAvailable: true)
        ColorfulButtonView(action: nil,
                           text: Text(verbatim: "Up To Date"),
                           icon: "CheckIcon",
                           iconSize: 16,
                           updateAvailable: false)
        }
        .padding()
    }
}

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

struct MenuButtonView: View {
    var action: () -> Void
    var text: String
    var bold: Bool
    var icon: String
    var iconSize: Int
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer().frame(width: 16)
                Text(text)
                    .foregroundColor(.abDarkText)
                    .latoFont(weight: bold ? .bold : .regular)
                Spacer()
                if !icon.isEmpty {
                    Image(icon)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(height: CGFloat(iconSize))
                        .foregroundColor(.abLightText)
                    Spacer().frame(width: 26)
                }
            }
            .frame(width: 272, height: 22)
            .background(Color.white)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { inside in
            if inside {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

struct MenuButtonView_Previews: PreviewProvider {
    static var previews: some View {
        MenuButtonView(action: {}, text: "Test", bold: false, icon: "LinkIcon", iconSize: 16)
    }
}

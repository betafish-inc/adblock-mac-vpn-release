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

struct PlainButtonView: View {
    var action: () -> Void
    var text: String
    var width: Int
    var icon: String
    var bold: Bool
    var background: Color = .white
    var body: some View {
        Button(action: action) {
            ZStack {
                Text(text)
                    .foregroundColor(.abDarkText)
                    .latoFont(weight: bold ? .bold : .regular)
                    .frame(width: CGFloat(width), height: 40)
                    .background(background)
                if !icon.isEmpty {
                    Image(icon)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 13)
                        .foregroundColor(.abDarkText)
                        .offset(x: CGFloat((width / 2) - 22), y: 0)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .cornerRadius(6)
        .overlay(RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.abBorder, lineWidth: 1))
        .onHover { inside in
            if inside {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

struct PlainButtonView_Previews: PreviewProvider {
    static var previews: some View {
        PlainButtonView(action: {}, text: "Test Button", width: 256, icon: "NextIcon", bold: true)
    }
}

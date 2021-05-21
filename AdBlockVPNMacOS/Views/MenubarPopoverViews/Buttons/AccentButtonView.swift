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

import SwiftUI

struct AccentButtonView: View {
    var action: () -> Void
    var text: String
    var background: Color = .abPrimaryAccent
    var foreground: Color = .white
    var body: some View {
        Button(action: action) {
            Text(text)
                .frame(width: 272, height: 40)
                .background(background)
        }
        .foregroundColor(foreground)
        .cornerRadius(6)
        .buttonStyle(PlainButtonStyle())
        .latoFont(weight: .bold)
        .onHover { inside in
            if inside {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

struct AccentButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AccentButtonView(action: {}, text: "Test Button")
    }
}

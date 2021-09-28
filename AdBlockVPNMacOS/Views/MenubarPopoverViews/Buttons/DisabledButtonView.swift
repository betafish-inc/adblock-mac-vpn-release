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

struct DisabledButtonView: View {
    var text: Text
    var body: some View {
        Button {} label: {
            text
                .frame(width: 272, height: 40)
                .background(Color.abBorder)
        }
        .foregroundColor(Color.white)
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

struct DisabledButtonView_Previews: PreviewProvider {
    static var previews: some View {
        DisabledButtonView(text: Text(verbatim: "Test Button"))
    }
}

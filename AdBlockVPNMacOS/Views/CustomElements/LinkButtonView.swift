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

struct LinkButtonView: View {
    var action: () -> Void
    var text: Text
    var fontSize: CGFloat = 14
    var whiteText: Bool = false
    var center: Bool = true
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            text
                .underline()
                .multilineTextAlignment(center ? .center : .leading)
                .foregroundColor(whiteText ? .abButtonForeground : .abLinkColor)
        })
            .buttonStyle(PlainButtonStyle())
            .latoFont(weight: .bold, size: fontSize)
            .onHover { inside in
                if inside {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
            .customAccessibilityAddTraits(.isLink)
    }
}

struct LinkButtonView_Previews: PreviewProvider {
    static var previews: some View {
        LinkButtonView(action: {}, text: Text(verbatim: "Need Help? Need Help? Need Help? Need Help? Need Help? Need Help? Need Help?"))
            .frame(width: 320, height: 352)
    }
}

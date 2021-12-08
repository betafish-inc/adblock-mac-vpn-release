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

struct FooterBlockView: View {
    var footerText: String
    var linkAction: () -> Void
    var body: some View {
        ZStack {
            Rectangle().fill(Color.abHeaderBackground)
            HStack(alignment: .top, spacing: 0) {
                LinkButtonView(action: linkAction, text: Text(footerText), fontSize: 14, whiteText: false, center: false)
                .fixedSize(horizontal: false, vertical: true)
                .padding(EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 16))
                Spacer()
                Button {
                    if let url = URL(string: Constants.helpURL) {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    Image("HelpIcon", label: Text("Help", comment: "label for help icon"))
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .onHover { inside in
                            if inside {
                                NSCursor.pointingHand.push()
                            } else {
                                NSCursor.pop()
                            }
                        }
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.abLinkColor)
                .frame(width: 20, height: 20)
                .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 24))
            }
        }.fixedSize(horizontal: false, vertical: true)
    }
}

struct FooterBlockView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FooterBlockView(
                footerText: "Don't have an AdBlock account?",
                linkAction: {})
                .frame(width: 320, height: 352)
        }
    }
}

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

struct TopBarView: View {
    @EnvironmentObject var state: AppState
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.abHeaderBackground)
                .frame(width: 272, height: 56)
            if [.preferences, .account, .help, .locations, .appSettings].contains(state.viewToShow) {
                Button {
                    self.state.backButtonClick()
                } label: {
                    Image("BackArrowIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 18.76)
                        .onHover { inside in
                            if inside {
                                NSCursor.pointingHand.push()
                            } else {
                                NSCursor.pop()
                            }
                        }
                }
                .offset(x: -105, y: 0)
                .buttonStyle(PlainButtonStyle())
                Text(state.getViewTitle())
                    .latoFont()
                    .foregroundColor(.abDarkText)
            } else {
                if state.viewToShow != .acceptance {
                    Button { self.state.viewToShow = .preferences } label: {
                        Image("MenuIcon")
                            .onHover { inside in
                                if inside {
                                    NSCursor.pointingHand.push()
                                } else {
                                    NSCursor.pop()
                                }
                            }
                    }
                    .offset(x: -105, y: 0)
                    .buttonStyle(PlainButtonStyle())
                }
                Image("FullLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 147, height: 24)
            }
        }.frame(width: 272, height: 56)
    }
}

struct TopBarView_Previews: PreviewProvider {
    static var previews: some View {
        TopBarView()
    }
}

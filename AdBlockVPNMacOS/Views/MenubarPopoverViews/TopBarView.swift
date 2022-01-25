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

struct TopBarView: View {
    @EnvironmentObject var state: AppState
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.abHeaderBackground)
                .frame(width: 272, height: 56)
            if [.preferences, .account, .help, .contactSupportStepOne, .contactSupportStepTwo, .locations, .appSettings].contains(state.viewToShow) {
                Button {
                    self.state.backButtonClick()
                } label: {
                    Image("BackArrowIcon", label: Text("Back", comment: "Alt text for back button"))
                        .resizable()
                        .scaledToFit()
                        .frame(height: 18.76)
                }
                .offset(x: -105, y: 0)
                .buttonStyle(TopBarButtonStyle())
                Text(state.getViewTitle())
                    .latoFont()
                    .foregroundColor(.abDarkText)
                    .padding(.horizontal, 40) // Encourages long strings to wrap, rather than obscure the back button.
            } else {
                if state.viewToShow != .acceptance {
                    Button { self.state.viewToShow = .preferences } label: {
                        Image("MenuIcon", label: Text("Preferences", comment: "Alt text for preferences button"))
                    }
                    .offset(x: -105, y: 0)
                    .buttonStyle(TopBarButtonStyle())
                }
                Image("FullLogo", label: Text("AdBlock VPN", comment: "Alt text for AdBlock VPN logo"))
                    .resizable()
                    .scaledToFit()
                    .frame(height: 28)
            }
        }.frame(width: 272, height: 56)
    }
}

struct TopBarView_Previews: PreviewProvider {
    static var previews: some View {
        TopBarView().environmentObject(AppState())
    }
}

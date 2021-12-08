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

struct LandingView: View {
    @EnvironmentObject var state: AppState
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                Image(decorative: "FlagWorld").resizable().scaledToFit().frame(width: 120, height: 120)
                Image(decorative: "LogoIso").resizable().scaledToFit().frame(width: 93, height: 142).offset(x: 0, y: -22)
            }
            Spacer().frame(height: 5)
            Text("Log in to connect to AdBlock VPN and secure your connection", comment: "Instructions on landing page")
                .latoFont()
                .foregroundColor(.abDarkText)
                .multilineTextAlignment(.center)
            Spacer()
                .if(!state.showConnectionInfo) { $0.frame(height: 56) }
            Button(action: { self.state.viewToShow = .login }, label: { Text("Log In", comment: "Label for button to go to login page") }).buttonStyle(PrimaryButtonStyle())
            Spacer().frame(height: 24)
        }
        .frame(width: 272, height: state.showConnectionInfo ? 460 : 352)
        .background(Color.abBackground)
    }
}

struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView().environmentObject(AppState())
    }
}

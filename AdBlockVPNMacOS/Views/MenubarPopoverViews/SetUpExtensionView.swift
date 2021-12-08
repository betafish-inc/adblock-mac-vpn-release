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

struct SetUpExtensionView: View {
    @EnvironmentObject var state: AppState
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                Image("FlagWorldGrey",
                      label: Text("VPN disabled", comment: "Alt text for image on extension set up page"))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                Image(decorative: "LogoIso")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 93, height: 142)
                    .offset(x: 0, y: -22)
            }
            Spacer().frame(height: 5)
            Text("Please enable the AdBlock VPN system extension to start using AdBlock VPN.", comment: "Instructions on system extension set up page")
                .latoFont()
                .foregroundColor(.abDarkText)
                .multilineTextAlignment(.center)
            Spacer()
                .if(!state.showConnectionInfo) { $0.frame(height: 17) }
            LinkButtonView(action: {
                if let url = URL(string: Constants.permissionsHelpURL) {
                    NSWorkspace.shared.open(url)
                }
            }, text: Text("Need Help?", comment: "Link to help site"))
            Spacer().frame(height: 27)
            Button(action: {}, label: { Text("Log In", comment: "Label for button that takes user to login page") }).buttonStyle(DisabledButtonStyle())
            Spacer().frame(height: 24)
        }
        .frame(width: 320, height: state.showConnectionInfo ? 460 : 352)
        .background(Color.abBackground)
    }
}

struct SetUpExtensionView_Previews: PreviewProvider {
    static var previews: some View {
        SetUpExtensionView().environmentObject(AppState())
    }
}

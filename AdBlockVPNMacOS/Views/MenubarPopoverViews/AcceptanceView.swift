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

struct AcceptanceView: View {
    @EnvironmentObject var state: AppState
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Welcome to AdBlock VPN", comment: "Title of acceptance page")
                    .foregroundColor(.abDarkText)
                    .latoFont(weight: .bold)
                Spacer().frame(height: 6)
                Text("By proceeding, you are confirming you have read and accepted both of the following...", comment: "Text explaining acceptance of EULA and Privacy Policy")
                    .latoFont(size: 16)
                    .foregroundColor(.abLightText)
            }
            Spacer().frame(height: 16)
            Button(action: {
                if let url = URL(string: Constants.eulaURL) {
                    NSWorkspace.shared.open(url)
                }
            }, label: { Text("End User License Agreement", comment: "Link to EULA") }).buttonStyle(SecondaryButtonStyle(bold: true))
            Spacer().frame(height: 16)
            Button(action: {
                if let url = URL(string: Constants.privacyURL) {
                    NSWorkspace.shared.open(url)
                }
            }, label: { Text("Privacy Policy", comment: "Link to Privacy Policy") }).buttonStyle(SecondaryButtonStyle(bold: true))
            Spacer()
            VStack(alignment: .center) {
                LinkButtonView(
                    action: {
                        if let url = URL(string: Constants.newTicketURL) {
                            NSWorkspace.shared.open(url)
                        }
                    },
                    text:
                        Text("Questions? Chat with our support team", comment: "Link to support site"),
                    fontSize: 16)
                Spacer().frame(height: 13)
                Button(action: {
                    self.state.eulaAccepted = true
                    self.state.viewToShow = .landing
                }, label: {
                    Text("Accept and Continue", comment: "Label for button that accepts the EULA and takes the user to the next page of the intro flow")
                }).buttonStyle(PrimaryButtonStyle())
            }
            Spacer().frame(height: 25)
        }
        .frame(width: 272, height: state.showConnectionInfo ? 460 : 352)
        .background(Color.abBackground)
    }
}

struct AcceptanceView_Previews: PreviewProvider {
    static var previews: some View {
        AcceptanceView()
            .environmentObject(AppState())
    }
}

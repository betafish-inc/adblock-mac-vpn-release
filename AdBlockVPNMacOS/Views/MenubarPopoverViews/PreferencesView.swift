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

struct PreferencesView: View {
    @EnvironmentObject var state: AppState
    @ObservedObject var viewModel: PreferencesViewModel
    var body: some View {
        VStack {
            Group {
                if viewModel.showAccount() {
                    MenuButtonView(
                        action: { self.state.viewToShow = .account },
                        text: Text("Account", comment: "Label for button that takes the useer to the account page"),
                        bold: true,
                        icon: "NextIcon",
                        iconSize: 11
                    )
                    Spacer().frame(height: 16)
                    Divider().background(Color.abBorder).frame(width: 256)
                    Spacer().frame(height: 16)
                }
                MenuButtonView(action: { self.state.viewToShow = .appSettings },
                               text: Text("App Settings", comment: "Label for button that takes the user to the app settings page"),
                               bold: true,
                               icon: "NextIcon",
                               iconSize: 11
                )
                Spacer().frame(height: 16)
                Divider().background(Color.abBorder).frame(width: 256)
                Spacer().frame(height: 16)
                MenuButtonView(
                    action: { self.state.viewToShow = .help },
                    text: Text("Help & Feedback", comment: "Label for button that takes the user to the help and feedback page"),
                    bold: true,
                    icon: "NextIcon",
                    iconSize: 11
                )
            }
            Spacer()
            Button(action: { self.viewModel.disconnectAndQuit() }, label: {
                viewModel.isVpnConnected ?
                Text("Quit & Disconnect", comment: "Label for quit button when the VPN is connected") :
                Text("Quit", comment: "Label for quit button when the VPN is disconnected")
            }).buttonStyle(SecondaryButtonStyle(bold: true))
            Spacer().frame(height: 24)
        }
        .frame(width: 272, height: state.showConnectionInfo ? 460 : 352)
        .background(Color.abBackground)
        .foregroundColor(.abDarkText)
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView(viewModel: PreferencesViewModel(vpnManager: VPNManager(), authManager: AuthManager())).environmentObject(AppState())
    }
}

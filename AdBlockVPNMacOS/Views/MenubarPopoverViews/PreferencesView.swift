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
                Spacer().frame(height: 25)
                if viewModel.showAccount() {
                    MenuButtonView(action: {
                        self.state.viewToShow = .account
                    }, text: "Account", bold: true, icon: "NextIcon", iconSize: 11)
                    Spacer().frame(height: 16)
                    Divider().background(Color.abBorder).frame(width: 256)
                    Spacer().frame(height: 16)
                }
                MenuButtonView(action: {
                    self.state.viewToShow = .appSettings
                }, text: "App Settings", bold: true, icon: "NextIcon", iconSize: 11)
                Spacer().frame(height: 16)
                Divider().background(Color.abBorder).frame(width: 256)
                Spacer().frame(height: 16)
                MenuButtonView(action: {
                    self.state.viewToShow = .help
                }, text: "Help & Feedback", bold: true, icon: "NextIcon", iconSize: 11)
            }
            Spacer()
            Button(action: { self.viewModel.disconnectAndQuit() }, label: { Text(viewModel.isVpnConnected ? "Quit & Disconnect" : "Quit") })
                .buttonStyle(SecondaryButtonStyle(bold: true))
            Spacer().frame(height: 24)
        }
        .frame(width: 272, height: 352)
        .background(Color.white)
        .foregroundColor(.abDarkText)
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView(viewModel: PreferencesViewModel(vpnManager: VPNManager(), authManager: AuthManager())).environmentObject(AppState())
    }
}

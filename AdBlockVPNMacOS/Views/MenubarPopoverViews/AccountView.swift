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

struct AccountView: View {
    @EnvironmentObject var state: AppState
    @ObservedObject var viewModel: AccountViewModel
    var body: some View {
        VStack {
            MenuButtonView(action: {
                self.viewModel.openAccountManagement()
            }, text: Text("Manage Account", comment: "Label for button that links to the account management page"), bold: false, icon: "LinkIcon", iconSize: 16)
            .disabled(viewModel.isRequestingMagicLink)
            Spacer().frame(height: 16)
            Divider().background(Color.abBorder).frame(width: 256)
            Spacer().frame(height: 16)
            MenuButtonView(action: {
                self.viewModel.logOut()
                self.state.viewToShow = .landing
            }, text: Text("Sign Out", comment: "Label for button that signs the user out of their account (and the app)"), bold: false, icon: "", iconSize: 11)
            Spacer()
        }
        .frame(width: 272, height: 352)
        .background(Color.white)
        .foregroundColor(.abDarkText)
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(viewModel: AccountViewModel(vpnManager: VPNManager(), authManager: AuthManager()))
    }
}

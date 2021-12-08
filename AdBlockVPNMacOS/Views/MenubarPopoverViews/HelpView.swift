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

struct HelpView: View {
    @EnvironmentObject var state: AppState
    @ObservedObject var viewModel: HelpViewModel
    var body: some View {
        VStack {
            MenuButtonView(action: {
                self.viewModel.openFeedback()
            }, text: Text("Send Feedback", comment: "Label for button that opens a feedback page"), bold: false, icon: "LinkIcon", iconSize: 16)
            Spacer().frame(height: 16)
            Divider().background(Color.abBorder).frame(width: 256)
            Spacer().frame(height: 16)
            MenuButtonView(action: {
                self.viewModel.openHelp()
            }, text: Text("Get Help", comment: "Label for button that opens a help page"), bold: false, icon: "LinkIcon", iconSize: 16)
            Spacer()
        }
        .frame(width: 272, height: state.showConnectionInfo ? 460 : 352)
        .background(Color.white)
        .foregroundColor(.abDarkText)
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView(viewModel: HelpViewModel())
    }
}

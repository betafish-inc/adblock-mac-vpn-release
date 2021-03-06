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
            }, text: Text("Request Feature", comment: "Label for button that opens a feedback page to request feedback"),
                           bold: true,
                           icon: "LinkIcon",
                           iconSize: 16)
                .customAccessibilityAddTraits(.isLink)
            Spacer().frame(height: 8)
            Divider().background(Color.abBorder).frame(width: 256)
            Spacer().frame(height: 8)
            MenuButtonView(action: {
                self.viewModel.openHelp()
            }, text: Text("Visit Help Center", comment: "Label for button that opens a help page"),
                           bold: true,
                           icon: "LinkIcon",
                           iconSize: 16)
            .customAccessibilityAddTraits(.isLink)
            Spacer().frame(height: 8)
            Divider().background(Color.abBorder).frame(width: 256)
            Spacer().frame(height: 8)
            MenuButtonView(action: {
                self.state.viewToShow = .contactSupportStepOne
            }, text: Text("Contact Support", comment: "Label for button that takes the user to a contact support page"),
                           bold: true,
                           icon: "NextIcon",
                           iconSize: 14)

            Spacer()
        }
        .frame(width: 272, height: state.showConnectionInfo ? 460 : 352)
        .background(Color.abBackground)
        .foregroundColor(.abDarkText)
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView(viewModel: HelpViewModel())
            .environmentObject(AppState())
    }
}

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
                Text("Welcome to AdBlock VPN")
                    .foregroundColor(.abDarkText)
                    .latoFont(weight: .bold)
                // swiftlint:disable:next line_length
                HTMLStringView(htmlContent: "By proceeding, you are confirming you have read and accepted the <a href='\(Constants.eulaURL)'>End User License Agreement (EULA)</a>, and our <a href='\(Constants.privacyURL)'>Privacy Policy</a>.",
                               fontSize: 16,
                               centered: false)
            }
            Spacer()
            VStack(alignment: .center) {
                HTMLStringView(htmlContent: "Questions? <a href='\(Constants.newTicketURL)'>Chat with our support team</a>", fontSize: 12, centered: true)
                Spacer().frame(height: 13)
                AccentButtonView(action: {
                    self.state.eulaAccepted = true
                    self.state.viewToShow = .landing
                }, text: "Accept and Continue")
            }
            Spacer().frame(height: 25)
        }
        .frame(width: 272, height: 352)
        .background(Color.white)
    }
}

struct AcceptanceView_Previews: PreviewProvider {
    static var previews: some View {
        AcceptanceView()
    }
}

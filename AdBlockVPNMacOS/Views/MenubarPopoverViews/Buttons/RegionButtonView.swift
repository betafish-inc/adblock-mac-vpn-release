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

struct RegionButtonView: View {
    @EnvironmentObject var state: AppState
    @ObservedObject var viewModel: ConnectionViewModel
    var flag: String
    var name: String
    var selected: Bool
    var id: String
    var body: some View {
        Button {
            self.state.viewToShow = .connection
            self.viewModel.changeGeo(newGeo: self.id)
        } label: {
            HStack {
                Spacer().frame(width: 15)
                Image(selected ? "CheckIcon" : flag)
                    .renderingMode(selected ? .template : .original)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 24)
                Spacer().frame(width: 16)
                Text(name)
                    .latoFont()
                Spacer()
            }
            .frame(width: 240, height: 40)
            .background(selected ? Color.abPrimaryAccent : Color.white)
            .foregroundColor(selected ? .white : .abDarkText)
        }
        .cornerRadius(6)
        .buttonStyle(PlainButtonStyle())
        .onHover { inside in
            if inside {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

struct RegionButtonView_Previews: PreviewProvider {
    static var previews: some View {
        RegionButtonView(viewModel: ConnectionViewModel(vpnManager: VPNManager(),
                                                        authManager: AuthManager(),
                                                        logManager: LogManager(),
                                                        notificationManager: NotificationManager(),
                                                        errorManager: ErrorManager()),
                         flag: "FlagWorld",
                         name: "Nearest location",
                         selected: false,
                         id: "nearest")
    }
}

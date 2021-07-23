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

struct RegionSelectionView: View {
    @ObservedObject var viewModel: ConnectionViewModel
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.connection.availableGeos) { geo in
                    RegionButtonView(viewModel: self.viewModel,
                                     flag: GeoAssets.flags[geo.id] ?? "FlagWorld",
                                     name: geo.name,
                                     selected: self.viewModel.connection.selectedGeo == geo.id,
                                     id: geo.id)
                }
            }.frame(width: 272)
            // Add padding to bottom of ScrollView
            Spacer().frame(height: 24)
        }
        .frame(width: 272, height: 352, alignment: .leading)
    }
}

struct RegionSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        RegionSelectionView(viewModel: ConnectionViewModel(vpnManager: VPNManager(),
                                                           authManager: AuthManager(),
                                                           logManager: LogManager(),
                                                           notificationManager: NotificationManager(),
                                                           errorManager: ErrorManager()))
    }
}

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
    @EnvironmentObject var state: AppState
    @ObservedObject var viewModel: ConnectionViewModel
    @State private var searchTerm = ""
    var body: some View {
        VStack {
            SearchBar(searchText: $searchTerm)
            Spacer().frame(height: 8)
            ScrollView {
                HStack {
                    Spacer().frame(width: 2)
                    VStack(spacing: 0) {
                        ForEach(
                            viewModel.connection.availableGeos.filter({
                                                                        searchTerm.isEmpty ? true : GeoAssets.getGeoName(id: $0.id).lowercased().contains(searchTerm)
                        })) { geo in
                            RegionButtonView(viewModel: self.viewModel,
                                             flag: GeoAssets.flags[geo.id] ?? "FlagWorld",
                                             name: GeoAssets.getGeoName(id: geo.id),
                                             selected: self.viewModel.connection.selectedGeo == geo.id,
                                             id: geo.id)
                        }
                    }.frame(width: 240)
                    Spacer()
                }
                // Add padding to bottom of ScrollView
                Spacer().frame(height: 24)
            }
            .frame(width: 272, height: state.showConnectionInfo ? 396 : 288, alignment: .leading)
        }
        .background(Color.white)
        .frame(width: 272, height: state.showConnectionInfo ? 460 : 352, alignment: .leading)
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

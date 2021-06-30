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

struct ErrorView: View {
    @ObservedObject var viewModel: ErrorViewModel
    var body: some View {
        VStack {
            VStack {
                Spacer().frame(height: 8)
                Image("Alert")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 112, height: 139)
                Spacer().frame(height: 30)
                Text("Oh dear. Something went wrong.")
                    .latoFont()
                    .foregroundColor(.abDarkText)
            }
            Spacer()
            ZStack(alignment: .center) {
                Rectangle()
                    .fill(Color.abErrorAccent)
                VStack(alignment: .center) {
                    HStack(alignment: .center) {
                        MultiLinkTextField(content: viewModel.errorString.text,
                                           fontSize: 14,
                                           centered: true,
                                           backgroundColor: .abErrorAccent,
                                           textColor: .white,
                                           accentColorLinks: false,
                                           localLinks: nil,
                                           webLinks: viewModel.errorString.links)
                            .frame(width: 300)
                            .fixedSize(horizontal: true, vertical: true)
                    }
                }
            }.frame(width: 320, height: 118)
        }
        .frame(width: 320, height: 352)
        .background(Color.white)
        .foregroundColor(Color.black)
        .latoFont()
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(viewModel: ErrorViewModel(errorManager: ErrorManager()))
    }
}

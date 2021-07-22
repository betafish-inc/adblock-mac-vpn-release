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

struct UpdatesErrorView: View {
    @EnvironmentObject var state: AppState
    @ObservedObject var viewModel: UpdatesViewModel
    var body: some View {
        VStack {
            Spacer().frame(height: 5)
            Image("Alert")
                .resizable()
                .scaledToFit()
                .frame(width: 144, height: 144)
            Spacer().frame(height: 25)
            Text("Something went wrong while attempting to update AdBlock VPN. Please try again. ")
                .multilineTextAlignment(.center)
                .latoFont()
                .foregroundColor(.abDarkText)
            Spacer()
            Button(action: {
                viewModel.openDownloadsPage()
                state.viewToShow = .connection
            }, label: { Text("Update") })
            .buttonStyle(PrimaryButtonStyle(buttonColor: .abUpdateAccent, buttonHoverColor: .abUpdateAccent, buttonClickColor: .abUpdateAccentClick, textColor: .abDarkText))
            Spacer().frame(height: 24)
        }
        .frame(width: 272, height: 352)
        .background(Color.abAccentBackground)
    }
}

struct UpdatesErrorView_Previews: PreviewProvider {
    static var previews: some View {
        UpdatesErrorView(viewModel: UpdatesViewModel(updateManager: UpdateManager(logManager: LogManager()))).environmentObject(AppState())
    }
}
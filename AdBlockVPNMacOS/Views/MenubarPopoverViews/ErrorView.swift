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
    @EnvironmentObject var state: AppState
    @ObservedObject var viewModel: ErrorViewModel
    var body: some View {
        VStack {
            VStack {
                Spacer().frame(height: state.showConnectionInfo ? 58 : 8)
                Image("Alert", label: Text("Error", comment: "Alt text for alert icon"))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 112, height: 139)
                Spacer().frame(height: 30)
                Text("Oh dear. Something went wrong.", comment: "Title for error view")
                    .latoFont()
                    .foregroundColor(.abDarkText)
            }
            Spacer()
            if viewModel.errorString.inlineLink {
                ErrorBlockView(
                    errorText: viewModel.errorString.text,
                    linkAction: {
                        if let urlString = viewModel.errorString.link, let url = URL(string: urlString) {
                            NSWorkspace.shared.open(url)
                        }
                    },
                    dismissError: nil,
                    showHelp: true,
                    helpURL: Constants.helpURL
                )
            } else {
                ErrorBlockView(
                    errorText: viewModel.errorString.text,
                    linkAction: nil,
                    dismissError: nil,
                    showHelp: true,
                    helpURL: viewModel.errorString.link ?? Constants.helpURL
                )
            }
        }
        .frame(width: 320, height: state.showConnectionInfo ? 460 : 352)
        .background(Color.abBackground)
        .latoFont()
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(viewModel: ErrorViewModel(errorManager: ErrorManager()))
            .environmentObject(AppState())
    }
}

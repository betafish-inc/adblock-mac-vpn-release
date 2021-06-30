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

struct OnboardingTopBarView: View {
    let currentView: OnboardingViews

    var body: some View {
        VStack {
            Spacer().frame(height: 12)
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.abHeaderBackground)
                .frame(height: 56)
                .overlay(
                    HStack {
                        Text("AdBlock VPN Setup")
                            .latoFont(weight: .bold)
                            .foregroundColor(.abDarkText)
                            .padding(.leading, 48)
                        Spacer()
                        if [.VPNConfigError, .sysExtensionError, .appMove].contains(currentView) {
                            EmptyView()
                        } else {
                            Circle().frame(width: 12, height: 12)
                                .foregroundColor(.abPrimaryAccent)
                            Circle().frame(width: 12, height: 12)
                                .foregroundColor(currentView >= OnboardingViews.sysExtension ? .abPrimaryAccent : .abSecondaryHeaderBackground)
                            Circle().frame(width: 12, height: 12)
                                .foregroundColor(currentView >= OnboardingViews.VPNConfig ? .abPrimaryAccent : .abSecondaryHeaderBackground)
                            Circle().frame(width: 12, height: 12)
                                .foregroundColor(currentView >= OnboardingViews.notifications ? .abPrimaryAccent : .abSecondaryHeaderBackground)
                            Circle().frame(width: 12, height: 12)
                                .foregroundColor(currentView >= OnboardingViews.complete ? .abPrimaryAccent : .abSecondaryHeaderBackground)
                                .padding(.trailing, 24)
                        }
                    }
                )
        }
    }
}

struct OnboardingTopBarView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(OnboardingViews.allCases, id: \.self) { view in
            OnboardingTopBarView(currentView: view)
                .frame(width: 576)
                .padding()
                .background(Color.white)
        }
    }
}

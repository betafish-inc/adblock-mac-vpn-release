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

struct OnboardingIntroView: View {
    @EnvironmentObject var model: OnboardingViewModel

    var body: some View {
        VStack {
            OnboardingBodyView(headerImage: "OnboardingIntro",
                               bodyTitle: "Thanks for installing AdBlock VPN")
            HStack {
                Text("You'll need to change a couple of permissions on your device in order to use AdBlock VPN. We'll walk you through how to do that now.")
                    .latoFont()
                    .foregroundColor(.abDarkText)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            Spacer().frame(height: 48)
            HStack {
                Spacer()
                Button(action: { model.checkViewToShow() }, label: { Text("Get Started") }).buttonStyle(PrimaryButtonStyle())
            }
            .fixedSize(horizontal: false, vertical: true)
            Spacer().frame(height: 32)
        }
    }
}

struct OnboardingIntroView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingIntroView()
            .frame(width: 576)
    }
}

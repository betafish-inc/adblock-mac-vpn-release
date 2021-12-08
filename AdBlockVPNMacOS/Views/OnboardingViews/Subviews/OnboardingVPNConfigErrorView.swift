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

struct OnboardingVPNConfigErrorView: View {
    @EnvironmentObject var model: OnboardingViewModel

    var body: some View {
        VStack {
            OnboardingBodyView(headerImage: "OnboardingError",
                               headerImageLabel: Text("Error", comment: "Alt text for onboarding error page image header"),
                               bodyTitle: Text("Oops!", comment: "Title for onboarding flow error page"))
            Text("It looks like we still don't have permission to add VPN configurations to your device. Let's try again.",
                 comment: "Instructions for VPN configuration error page in onboarding flow")
                .latoFont()
                .foregroundColor(.abDarkText)
                .fixedSize(horizontal: false, vertical: true)
            Spacer().frame(height: 48)
            HStack(spacing: 32) {
                OnboardingContactSupportButtonView()
                Button(action: { model.checkViewToShow() }, label: { Text("Try Again", comment: "Label for button to try the step again") }).buttonStyle(PrimaryButtonStyle())
            }
            .fixedSize(horizontal: false, vertical: true)
            Spacer().frame(height: 32)
        }
    }
}

struct OnboardingVPNConfigErrorView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingVPNConfigErrorView()
            .environmentObject(OnboardingViewModel(vpnManager: VPNManager(), notificationManager: NotificationManager()))
            .frame(width: 576)
    }
}

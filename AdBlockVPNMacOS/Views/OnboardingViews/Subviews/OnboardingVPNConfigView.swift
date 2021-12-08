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

struct OnboardingVPNConfigView: View {
    @EnvironmentObject var model: OnboardingViewModel

    var body: some View {
        VStack {
            OnboardingBodyView(headerImage: "OnboardingVPNConfiguration",
                               headerImageLabel: nil,
                               bodyTitle: Text("Allow AdBlock VPN to add VPN configurations", comment: "Title for VPN configuration page of onboarding flow"))
            // swiftlint:disable:next line_length
            Text("Click “Open System Dialog” below. In the following window, click the ”Allow” button. When you're done, click ”Next Steps” below to continue the setup process.", comment: "Instructions for VPN configuration page of onboarding flow")
                .latoFont()
                .foregroundColor(.abDarkText)
                .fixedSize(horizontal: false, vertical: true)
            Spacer().frame(height: 48)
            HStack(spacing: 32) {
                Button(action: { model.installVPNProfile() }, label: { Text("Open System Dialog", comment: "Label for button that opens the system dialog") })
                    .buttonStyle(SecondaryButtonStyle())
                    .disabled(model.vpnProfileActive)
                Button(action: { model.vpnProfileActive ? model.checkViewToShow() : (model.viewToShow = .VPNConfigError) },
                       label: { Text("Next Steps", comment: "Label for button that take the user to the next step in the onboarding flow") })
                    .buttonStyle(PrimaryButtonStyle())
            }
            .fixedSize(horizontal: false, vertical: true)
            Spacer().frame(height: 32)
        }
    }
}

struct OnboardingVPNConfigView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingVPNConfigView()
            .environmentObject(OnboardingViewModel(vpnManager: VPNManager(), notificationManager: NotificationManager()))
            .frame(width: 576)
    }
}
